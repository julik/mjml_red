# Nokogiri XML Preprocessing Hacks in Renderer

## Status: HACK — revisit later

## The fundamental problem

MJML is a hybrid format: it uses XML-like structure (`<mj-section>`, `<mj-column>`) but
embeds raw HTML content inside certain components (`<mj-text>`, `<mj-table>`, `<mj-raw>`).
We parse MJML with `Nokogiri::XML`, which doesn't understand HTML conventions. This causes
three classes of breakage:

### 1. HTML void elements break XML parsing

HTML void elements like `<br>`, `<hr>`, `<img>` (without a closing slash) are invalid XML.
Nokogiri::XML treats `<br>` as an opening tag with no closing tag, causing everything after
it to become a child of `<br>`. Siblings (comments, text, other elements) after an unclosed
void element get swallowed.

**Example:** Inside `<mj-text>`, the content:
```html
<!-- comment 1 -->
<br>
<!-- comment 2 -->
```
...loses comment 2 because XML thinks it's inside `<br>`.

### 2. Bare `<` in template syntax breaks XML parsing

`<mj-raw>` is used to inject raw template engine directives like `{ if item < 5 }`.
The `<` character is interpreted by the XML parser as the start of a tag, producing
malformed/lost content.

### 3. `>` in template syntax gets entity-encoded on serialization

Even when parsing succeeds, `Nokogiri::XML` serialization (`to_xml`, `to_html`) encodes
`>` as `&gt;` in text nodes. Template syntax like `{ if item > 10 }` becomes
`{ if item &gt; 10 }` in the output, which breaks template engines consuming the HTML.

## Why not Nokogiri::HTML5?

We tried switching to `Nokogiri::HTML5` which solves problems 1-3 natively. However,
HTML5 parsing introduces a **worse** problem: **foster parenting**.

HTML5's table parsing algorithm requires that `<tr>`, `<td>`, `<th>` elements only appear
inside `<table>`/`<tbody>`/`<thead>`/`<tfoot>`. When they appear inside an unknown element
like `<mj-table>`, HTML5 parsing foster-parents them out — the tags are stripped and only
the text content remains.

**Example:** `<mj-table><tr><td>One</td><td>Two</td></tr></mj-table>` becomes
`<mj-table>One Two</mj-table>` under HTML5 parsing.

Similarly, `<mj-raw>` content rendered inside a `<tbody>` (via mj-column's table layout)
gets foster-parented out of the table, destroying the intended document order.

This is a fundamental incompatibility — MJML components like mj-table rely on passing
through raw HTML table markup, and mj-column renders children inside `<table><tbody>`,
interspersing raw mj-raw content between `<tr>` rows.

## Current workarounds (renderer.rb)

### Workaround A: Void element self-closing conversion (fixes problem 1)

**Location:** `Renderer.call`, before `Nokogiri::XML()` parsing.

```ruby
VOID_ELEMENTS_RE = /(<(?:br|hr|img|input|meta|link|area|base|col|embed|param|source|track|wbr)(?:\s[^>]*)?)>/i

preprocessed = mjml_string.gsub(VOID_ELEMENTS_RE, '\1/>')
```

Converts `<br>` to `<br/>`, `<img src="x">` to `<img src="x"/>`, etc. This makes them
valid self-closing XML elements so the parser doesn't treat subsequent siblings as children.

**Known limitations:**
- Regex-based: could match inside attribute values or CDATA in pathological inputs.
  In practice MJML content doesn't have these edge cases.
- Only covers the standard 14 HTML void elements. If users write custom void-like elements
  they won't be converted.

### Workaround B: Bare `<` placeholder escaping (fixes problem 2)

**Location:** `Renderer.call`, before `Nokogiri::XML()` parsing. Also in the
html_attributes post-processing step.

```ruby
RAW_LT_PLACEHOLDER = "___MJML_RAW_LT___"

preprocessed = preprocessed.gsub(/<(?![a-zA-Z\/!?])/, RAW_LT_PLACEHOLDER)
```

The regex `/<(?![a-zA-Z\/!?])/` matches `<` characters that are NOT followed by:
- A letter (start of an element tag like `<div`)
- `/` (end tag like `</div`)
- `!` (comment `<!--` or CDATA `<![CDATA[` or doctype `<!DOCTYPE`)
- `?` (processing instruction `<?xml`)

These are "bare" `<` characters that appear in text content — template syntax like
`{ if item < 5 }`, comparison operators, etc. They get replaced with a unique placeholder
string before XML parsing, then restored after content extraction:

```ruby
# In nokogiri_to_hash, when extracting ending-tag component content:
inner.gsub(RAW_LT_PLACEHOLDER, "<")
```

**Known limitations:**
- The placeholder string `___MJML_RAW_LT___` could theoretically appear in user content.
  Astronomically unlikely in practice.
- Only protects `<` in text content. If template syntax appears inside an XML attribute
  value, it would still break (but MJML doesn't support this).

### Workaround C: Custom XML fragment serializer (fixes problem 3)

**Location:** `Renderer.serialize_fragment` / `Renderer.serialize_node`, used only by
the html_attributes post-processing step.

```ruby
def self.serialize_node(node)
  if node.text?
    node.text          # Raw text, NOT entity-encoded
  elsif node.comment?
    "<!--#{node.content}-->"
  elsif node.element?
    attrs = node.attributes.values.map { |a|
      val = a.value.gsub("&", "&amp;").gsub('"', "&quot;")
      " #{a.name}=\"#{val}\""
    }.join
    if VOID_ELEMENTS.include?(node.name) && node.children.empty?
      "<#{node.name}#{attrs}>"
    else
      "<#{node.name}#{attrs}>#{serialize_fragment(node)}</#{node.name}>"
    end
  else
    node.to_html
  end
end
```

The key difference from Nokogiri's built-in `to_xml`/`to_html`: text nodes use `.text`
(which returns unencoded content) instead of the serializer encoding `>` as `&gt;`.

This is only needed for the **html_attributes step** (`<mj-html-attributes>`), which
re-parses the already-rendered body HTML with `Nokogiri::XML.fragment` to apply CSS
selector-based attribute injection. The re-parsing + Nokogiri serialization would
otherwise encode `>` in template text that was already correctly literal.

**Known limitations:**
- The custom serializer is minimal. It handles text, comments, and elements but falls
  back to `node.to_html` for other node types (CDATA, processing instructions, etc.).
- Attribute value escaping is manual (`&` and `"` only). This covers all practical cases
  in MJML output but isn't a full XML/HTML attribute escaping implementation.
- Void element detection uses a hardcoded list matching the HTML spec. Custom void-like
  elements would serialize with a closing tag instead of self-closing.

## Where all three workarounds apply

| Step in pipeline               | Workaround A (void) | Workaround B (bare <) | Workaround C (serializer) |
|-------------------------------|---------------------|----------------------|--------------------------|
| Initial MJML parsing          | Yes                 | Yes                  | No                       |
| Content extraction (nokogiri_to_hash) | N/A         | Yes (unescape)       | No                       |
| Before-doctype mj-raw extraction | N/A              | Yes (unescape)       | No                       |
| html_attributes post-processing | N/A               | Yes (escape+unescape)| Yes                      |

## Possible future alternatives

1. **Write a custom MJML parser** that handles the hybrid XML/HTML nature directly,
   instead of relying on Nokogiri::XML with preprocessing. The upstream JS MJML uses
   its own parser that treats component content as opaque strings.

2. **Use Nokogiri::HTML5 for initial parsing but protect ending-tag content** by
   extracting it with regex before parsing and reinserting after. This would let HTML5
   handle the structural parsing while preserving raw content. Risk: regex extraction
   of nested elements is fragile.

3. **Use a SAX/streaming parser** that yields events for MJML structure but captures
   content regions as raw strings without attempting to parse them.

4. **Use Oga** (pure Ruby XML/HTML parser) which may have different trade-offs around
   strictness and content preservation.
