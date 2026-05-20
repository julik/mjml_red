# Plan: Pure-Ruby MJML Port (`mjml_red`)

## Overview

A pure-Ruby implementation of MJML (the email templating language) using Nokogiri for XML parsing. No Rust, no shelling out to Node — just Ruby transforming `<mjml>` XML into email-safe HTML with table-based layouts, Outlook conditionals, and responsive media queries.

## Architecture Summary

MJML's pipeline is straightforward:

```
MJML XML string
  → Parse to DOM (Nokogiri)
  → Process <mj-head> children (collect metadata: styles, fonts, breakpoint, default attrs, classes)
  → Apply mj-class and mj-attributes defaults onto body nodes
  → Recursively render <mj-body> tree (each component emits HTML strings)
  → Wrap in HTML skeleton (doctype, head styles, media queries, fonts, Outlook conditionals)
  → Inline CSS (using a Ruby CSS inliner)
  → Merge/minify Outlook conditionals
  → Return HTML string
```

This maps cleanly to Ruby. The JS version uses `htmlparser2` (a lenient HTML parser); we can use Nokogiri in XML mode since MJML is well-formed XML.

---

## Dependencies

- **nokogiri** — XML parsing (already in Gemfile)
- **css_inline** or **roadie** — CSS inlining (replaces JS `juice`). `css_inline` is faster (Rust-backed but available as a gem with prebuilt binaries, very different from "porting to Rust"). Alternatively `roadie` is pure-Ruby. Recommend `css_inline` for performance, fall back to `roadie` if purity matters more.
- No other runtime dependencies needed.

---

## Module/Class Structure

```
lib/
  mjml_red.rb                       # Entry point: MjmlRed.to_html(mjml_string, options)
  mjml_red/
    version.rb
    parser.rb                       # Nokogiri XML parsing → node tree
    renderer.rb                     # Orchestrates the full pipeline
    global_data.rb                  # Mutable struct collecting head metadata
    skeleton.rb                     # HTML skeleton template
    helpers/
      shorthand_parser.rb           # CSS shorthand → directional values
      width_parser.rb               # "50%" → {value: 50, unit: "%"}
      conditional_tag.rb            # Outlook conditional comment helpers
      suffix_css_classes.rb         # Appends suffix to CSS class names
      media_queries.rb              # Builds @media query blocks
      fonts.rb                      # Builds font @import tags
      styles.rb                     # Builds <style> blocks from components
    component.rb                    # Base Component class
    body_component.rb               # BodyComponent with styles/rendering helpers
    head_component.rb               # HeadComponent with handler pattern
    components/
      head/
        mj_head.rb                  # Container, delegates to children
        mj_attributes.rb            # Registers default attributes + mj-class
        mj_style.rb                 # Collects CSS (inline or block)
        mj_font.rb                  # Registers custom fonts
        mj_title.rb                 # Sets <title>
        mj_preview.rb               # Sets preview text
        mj_breakpoint.rb            # Overrides responsive breakpoint
        mj_html_attributes.rb       # Applies HTML attributes to selectors
      body/
        mj_body.rb                  # Body container, sets 600px width
        mj_section.rb               # Full-width table rows with background support
        mj_column.rb                # Column layout with width calculation
        mj_group.rb                 # Groups columns (extends section logic)
        mj_wrapper.rb               # Full-width wrapper (extends section)
        mj_text.rb                  # Text content
        mj_image.rb                 # Images with responsive sizing
        mj_button.rb                # Styled button links
        mj_divider.rb               # Horizontal rules
        mj_spacer.rb                # Vertical spacing
        mj_table.rb                 # Raw HTML tables
        mj_raw.rb                   # Pass-through HTML
        mj_hero.rb                  # Hero section with background
        mj_social.rb                # Social icons container
        mj_social_element.rb        # Individual social icon
        mj_navbar.rb                # Navigation bar
        mj_navbar_link.rb           # Navigation link
        mj_carousel.rb              # Image carousel
        mj_carousel_image.rb        # Carousel item
        mj_accordion.rb             # Accordion container
        mj_accordion_element.rb     # Accordion item
        mj_accordion_title.rb       # Accordion title
        mj_accordion_text.rb        # Accordion content
    registry.rb                     # Component registry + dependency validation
```

---

## Implementation Phases

### Phase 1: Core Infrastructure

**Goal:** Get the pipeline working end-to-end with a trivial MJML document.

1. **Parser** (`parser.rb`)
   - Use `Nokogiri::XML(mjml_string)` to parse input
   - Walk the DOM tree, no need to convert to an intermediate AST — Nokogiri nodes *are* the AST
   - Each Nokogiri element maps directly to a component via its tag name
   - Handle `content` extraction for "ending tag" components (mj-text, mj-button, etc.) — their inner HTML is the `content` property, not parsed as child components

2. **Component base classes** (`component.rb`, `body_component.rb`, `head_component.rb`)
   - `Component`: stores attributes, children (Nokogiri child elements), content, context hash
   - `BodyComponent < Component`:
     - `#get_styles` → returns hash of named style groups
     - `#html_attributes(attrs)` → builds HTML attribute string, with `style:` key auto-resolving through `#styles`
     - `#styles(name_or_hash)` → converts style hash to inline CSS string
     - `#render_children(children, opts)` → iterates children, instantiates components, calls render
     - `#get_shorthand_attr_value(attr, direction)` — CSS shorthand parsing
     - `#get_box_widths` — padding/border-aware width calculation
   - `HeadComponent < Component`:
     - `#handler` — modifies global_data, no HTML output
     - `#handler_children` — processes child head components

3. **GlobalData** (`global_data.rb`)
   - Simple struct/class holding: `breakpoint`, `classes`, `classes_default`, `default_attributes`, `fonts`, `inline_style`, `head_style`, `components_head_style`, `media_queries`, `preview`, `style`, `title`, `head_raw`, `html_attributes`, `lang`, `dir`, `force_owa_desktop`, `before_doctype`
   - `#add(key, *params)` — same merge semantics as JS version

4. **Registry** (`registry.rb`)
   - Hash mapping tag names → component classes
   - `register_component(klass)`
   - `MjmlRed.components` — the global registry
   - All standard components auto-registered on require

5. **Renderer** (`renderer.rb`)
   - Orchestrates: parse → head processing → attribute application → body rendering → skeleton → CSS inlining → cleanup
   - Returns `{ html: String, errors: Array }`

6. **Skeleton** (`skeleton.rb`)
   - ERB or string interpolation template producing the full HTML document
   - Includes: doctype, Outlook conditionals, reset CSS, font imports, media queries, component styles, custom styles

7. **Helpers** — direct ports of the JS helpers, all simple string manipulation

### Phase 2: Head Components

All head components just modify `global_data` — no HTML rendering. Simple to port.

1. **mj-head** — container, calls `handler_children`
2. **mj-attributes** — iterates children (`<mj-all>`, `<mj-class>`, `<mj-text>`, etc.), sets `global_data.default_attributes` and `global_data.classes`
3. **mj-style** — pushes CSS text to `global_data.style` or `global_data.inline_style`
4. **mj-font** — registers font name → URL in `global_data.fonts`
5. **mj-title** — sets `global_data.title`
6. **mj-preview** — sets `global_data.preview`
7. **mj-breakpoint** — sets `global_data.breakpoint`
8. **mj-html-attributes** — stores selector → attribute mappings

### Phase 3: Structural Body Components

The core layout engine. These are the most complex components.

1. **mj-body** — sets container width (default 600px), renders children, wraps in `<body>` + accessibility div
2. **mj-section** — the workhorse:
   - Table-based layout with Outlook conditional wrappers
   - Background image support with VML fallback for Outlook
   - Full-width mode
   - Renders columns as wrapped children with Outlook `<td>` wrappers
3. **mj-column** — the second workhorse:
   - Width calculation: percentage or pixel, divided among siblings
   - Mobile width (100% on small screens)
   - Generates responsive CSS class names (`mj-column-per-50`)
   - Registers media queries via context
   - Gutter (padding) support with nested table
   - Renders children in `<tr><td>` wrappers with padding/alignment
4. **mj-wrapper** — extends mj-section with full-width semantics
5. **mj-group** — groups columns, similar to section

### Phase 4: Content Body Components

Simpler components that render content within the column structure.

1. **mj-text** — `<div>` with inline styles, optional height wrapper with Outlook table
2. **mj-image** — `<img>` tag with responsive width, optional link wrapper, fluid/full-width modes
3. **mj-button** — `<a>` styled as button, table-based for Outlook, inner padding
4. **mj-divider** — `<p>` with border-top styling, Outlook table wrapper
5. **mj-spacer** — empty `<div>` with height, Outlook conditional
6. **mj-table** — passes through raw table HTML, applies container styles
7. **mj-raw** — passes through raw HTML unchanged

### Phase 5: Advanced Body Components

More complex interactive/visual components.

1. **mj-hero** — hero section with background image (fixed/fluid modes), VML for Outlook
2. **mj-social** + **mj-social-element** — social icon grid with built-in icon URLs for common networks
3. **mj-navbar** + **mj-navbar-link** — horizontal nav with hamburger toggle for mobile
4. **mj-carousel** + **mj-carousel-image** — CSS-only image carousel with radio button navigation
5. **mj-accordion** + **mj-accordion-element/title/text** — CSS-only accordion with checkbox toggle

### Phase 6: Post-processing & Polish

1. **CSS inlining** — use `css_inline` gem (or `roadie`) to inline styles from `<mj-style inline="inline">`
2. **Outlook conditional merging** — merge adjacent `<!--[if mso | IE]>` blocks
3. **mj-html-attributes** post-processing — use Nokogiri to apply HTML attributes to matching CSS selectors in the rendered output
4. **Whitespace cleanup** — the JS version produces lots of whitespace from template literals; our Ruby version can be cleaner from the start, but optionally strip excessive whitespace

---

## Key Design Decisions

### 1. Use Nokogiri nodes directly, don't build a separate AST

The JS version converts HTML to a JSON AST then works with plain objects. In Ruby, Nokogiri nodes are already a rich DOM — we can read tag names, attributes, child elements, and inner HTML directly. This saves an entire abstraction layer.

Components receive the Nokogiri element + context, and read attributes via `node['attribute-name']`. Inner content (for mj-text etc.) is `node.inner_html`.

### 2. Context passing via a simple Hash

Each component receives a context hash: `{ components:, container_width:, global_data:, ... }`. Child components get a modified copy (e.g., updated `container_width`). This mirrors the JS approach without needing anything fancier.

### 3. String-based HTML generation

Like the JS version, components build HTML via string interpolation/heredocs. No need for a template engine — the output is all email-compatible HTML tables and divs.

### 4. Attribute type validation is optional

The JS version has a full type system for attribute validation (color, enum, unit, etc.). For the initial port, we can skip validation entirely — just pass attribute values through. We can add validation later as a separate concern. The rendering doesn't depend on validation.

### 5. No mj-include support initially

File inclusion (`<mj-include>`) is a parser-level feature. Skip it for v1 — users can pre-process their templates or we can add it later. The core rendering pipeline doesn't need it.

### 6. No minification/beautification initially

The JS version has htmlnano integration and a beautifier. Skip for v1. Users can post-process the HTML output if they need minification.

---

## What NOT to Port

- **CLI** (`mjml-cli`) — not needed, this is a library
- **Browser builds** (`mjml-browser`) — N/A
- **Validation** (`mjml-validator`) — skip for v1, add later
- **mj-include** — skip for v1
- **Minification/beautification** — skip for v1
- **Template syntax sanitization** — the JS version's elaborate `{{variable}}` protection during CSS minification is only needed for minification, which we're skipping
- **`.mjmlconfig` file support** — skip for v1
- **Custom component registration** — the architecture supports it naturally, but don't need explicit API for v1

---

## Testing Strategy

### Principle: Stay Close to Upstream Tests

The upstream MJML repo has **no snapshot tests**. Tests are behavioral — they render an MJML input string, parse the resulting HTML with Cheerio, and assert on specific CSS selectors/attribute values. The tests live in two places:

- `packages/mjml/test/*.test.js` — **~25 integration tests** covering specific component behaviors (accordion padding, column border-radius, table width, social alignment, navbar padding, wrapper gaps, html-attributes, etc.)
- `packages/mjml-core/tests/*.test.js` — **unit tests** for helpers (shorthandParser, widthParser, mergeOutlookConditionals, skeleton, etc.)

Each test follows the same pattern:
```js
const input = `<mjml>...<mj-section>...<mj-column>...<mj-text>...</mj-text>...</mj-column>...</mj-section>...</mjml>`
const { html } = await mjml(input)
const $ = load(html)  // Cheerio
expect($('.some-selector').attr('style')).to.contain('padding:40px')
```

### Two-layer test approach

**Layer 1: Golden-file HTML comparison (generated via Node)**

For every component, we maintain a set of MJML fixture files. A **Rake task shells out to the upstream Node MJML** (in `tmp/mjml/`) to produce the expected HTML output, saving it alongside the fixture:

```
test/
  fixtures/
    generate_expected.js            # Node script: reads *.mjml, writes *.expected.html
    Rakefile or rake task            # `rake fixtures:regenerate`
    mj_text/
      basic.mjml
      basic.expected.html           # Generated by Node, checked into git
      with_height.mjml
      with_height.expected.html
    mj_section/
      basic.mjml
      basic.expected.html
      full_width.mjml
      full_width.expected.html
      with_background.mjml
      with_background.expected.html
    mj_column/
      ...
```

The Ruby test loads the `.mjml`, renders via `MjmlRed.to_html`, and compares against `.expected.html`. Comparison should normalize whitespace (collapse runs of whitespace, strip leading/trailing) since the JS version produces messy whitespace from template literals and our Ruby output will differ. An HTML-aware diff (or just whitespace-normalized string comparison) is sufficient.

```ruby
# test/component_test.rb (Minitest example)
Dir["test/fixtures/**/*.mjml"].each do |mjml_path|
  expected_path = mjml_path.sub(/\.mjml$/, ".expected.html")
  define_method("test_#{mjml_path}") do
    mjml = File.read(mjml_path)
    expected = normalize_whitespace(File.read(expected_path))
    actual = normalize_whitespace(MjmlRed.to_html(mjml))
    assert_equal expected, actual
  end
end
```

**Regenerating expected output** when pulling upstream changes:

```bash
rake fixtures:regenerate  # runs: node test/fixtures/generate_expected.js
```

This script uses the `tmp/mjml` checkout to render each `.mjml` file and overwrite the `.expected.html` files. This makes it trivial to backport upstream fixes — update the MJML checkout, re-run the generator, see which tests break, fix our Ruby code.

**Layer 2: Behavioral tests ported from upstream**

The upstream `packages/mjml/test/*.test.js` tests are ported 1:1 to Ruby/Minitest. They use Nokogiri instead of Cheerio to query the rendered HTML:

```ruby
# test/upstream/accordion_padding_test.rb
class AccordionPaddingTest < Minitest::Test
  def test_renders_correct_padding_on_accordion_title_and_text
    input = <<~MJML
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-accordion>
                <mj-accordion-element>
                  <mj-accordion-title padding="20px" padding-bottom="40px" padding-left="40px" padding-right="40px" padding-top="40px">Why?</mj-accordion-title>
                  <mj-accordion-text padding="20px" padding-bottom="40px" padding-left="40px" padding-right="40px" padding-top="40px">Because.</mj-accordion-text>
                </mj-accordion-element>
              </mj-accordion>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    html = MjmlRed.to_html(input)
    doc = Nokogiri::HTML(html)

    %w[padding-left padding-right padding-top padding-bottom].each do |prop|
      values = doc.css(".mj-accordion-title td:first-child, .mj-accordion-content td:first-child").map do |td|
        extract_style(td["style"], prop)
      end
      assert_equal ["40px", "40px"], values, "#{prop} on accordion-title and accordion-text"
    end
  end
end
```

The upstream tests are small and self-contained so porting is mechanical. Each upstream `.test.js` file becomes a Ruby test file with the same assertions translated to Nokogiri selectors.

### Helper unit tests

The `packages/mjml-core/tests/` unit tests for `shorthandParser`, `widthParser`, `mergeOutlookConditionals`, etc. port directly to Ruby unit tests — they're pure input→output with no DOM involved.

### Keeping in sync with upstream

The design explicitly supports backporting:

1. `tmp/mjml/` is a checkout of upstream MJML (can be a git submodule or just a vendored copy)
2. `rake fixtures:regenerate` re-runs Node to produce fresh expected HTML
3. New upstream `.test.js` files can be ported to Ruby as they appear
4. The golden-file tests catch regressions from upstream behavioral changes automatically

**Requiring Node for test generation is fine** — it's a development/CI dependency only, not a runtime dependency. The gem itself remains pure Ruby + Nokogiri.

### Test categories

1. **Golden-file per component:** basic rendering, attributes, edge cases
2. **Upstream behavioral tests:** ported 1:1 from `packages/mjml/test/`
3. **Helper unit tests:** ported from `packages/mjml-core/tests/`
4. **Integration tests:** full documents with multiple components, head configuration, responsive output

---

## Estimated Complexity

| Phase | Components | Effort |
|-------|-----------|--------|
| Phase 1: Core | 7 files | Largest — the rendering pipeline |
| Phase 2: Head | 8 components | Small — all simple data collection |
| Phase 3: Structural | 5 components | Large — section/column are complex |
| Phase 4: Content | 7 components | Medium — mostly straightforward |
| Phase 5: Advanced | 10 components | Medium — carousel/accordion have tricky CSS |
| Phase 6: Post-processing | 3 features | Small — mostly using gems |

The critical path is Phase 1 + Phase 3. Once `mj-section` and `mj-column` render correctly, everything else is incremental.

---

## API

```ruby
# Basic usage
html = MjmlRed.to_html('<mjml><mj-body><mj-section>...</mj-section></mj-body></mjml>')

# With options
html = MjmlRed.to_html(mjml_string,
  fonts: { "Open Sans" => "https://fonts.googleapis.com/css?family=Open+Sans:300,400,500,700" },
  keep_comments: true,
  css_inline: true  # whether to run CSS inliner
)
```

Returns just the HTML string. Errors can be raised as exceptions or returned separately via an extended API if needed later.
