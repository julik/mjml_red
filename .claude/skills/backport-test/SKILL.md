---
name: backport-test
description: Convert an upstream MJML JS test file into a Ruby Minitest file with Nokogiri HTML assertions
argument-hint: <path-to-upstream-js-test>
---

# Backport upstream MJML JS test to Ruby Minitest

Read the upstream JS test file at: $ARGUMENTS

Then convert it into an equivalent Ruby Minitest file with Nokogiri-based HTML assertions, following the conventions below.

## Translation rules

### Test structure
- Each JS `describe` block becomes a Ruby test class inheriting from `Minitest::Test`
- Each JS `it` block becomes a `def test_...` method
- The test class name is derived from the describe string, PascalCased, suffixed with `Test`
- Place the output file in `test/upstream/` with a snake_cased filename matching the JS source name, e.g. `accordion-padding.test.js` → `test/upstream/accordion_padding_test.rb`

### Boilerplate
```ruby
# frozen_string_literal: true

require "test_helper"

class DescriptiveNameTest < Minitest::Test
  def test_description_from_it_block
    input = <<~MJML
      <mjml>
        ...
      </mjml>
    MJML

    html = Emjay.to_html(input)
    doc = Nokogiri::HTML(html)

    # assertions here
  end
end
```

### Assertion translations

| JS (Chai + Cheerio) | Ruby (Minitest + Nokogiri) |
|---|---|
| `const $ = load(html)` | `doc = Nokogiri::HTML(html)` |
| `$('.foo').attr('style')` | `doc.at_css('.foo')['style']` |
| `$('.foo').map(fn).get()` | `doc.css('.foo').map { \|el\| ... }` |
| `$(this).attr('data-id')` | `el['data-id']` |
| `expect(x).to.eql(y)` | `assert_equal y, x` |
| `expect(x).to.include(y)` | `assert_includes x, y` |
| `expect(x).to.not.include(y)` | `refute_includes x, y` |
| `expect(x).to.deep.eql(y)` | `assert_equal y, x` |

### Style extraction helper

When the JS test uses `extractStyle(style, prop)` to pull a CSS property value from an inline style string, use the same helper in Ruby. Assume a `extract_style(style_string, property_name)` helper is available in `test_helper.rb`:

```ruby
def extract_style(style, prop)
  return nil unless style
  match = style.match(/(?:^|;)\s*#{Regexp.escape(prop)}\s*:\s*([^;]+)/)
  match ? match[1].strip : nil
end
```

### MJML input strings
- Copy the MJML input strings verbatim from the JS test
- Use `<<~MJML` heredocs for readability
- Preserve the exact attribute values — these are the test fixtures

### Cheerio selector → Nokogiri selector
- Cheerio and Nokogiri both use CSS selectors, so most selectors translate directly
- `$(selector).map(function() { return $(this).attr('x') }).get()` becomes `doc.css(selector).map { |el| el['x'] }`
- `$(selector).first()` becomes `doc.at_css(selector)`
- For `.map().get()` patterns that return arrays, use `doc.css(...).map { ... }`

### What to skip
- Skip any tests that test CLI behavior (`watch-cli.test.js`, `include-path-cli.test.js`)
- Skip any tests that test `mj-include` file inclusion
- Skip tests that only test minification or beautification options
- If a test uses `extractStyle`, ensure the helper is called correctly

### Important
- Do NOT change the MJML input fixtures — they must match upstream exactly for backportability
- Do NOT simplify or "improve" the assertions — keep them as close to the JS originals as possible
- Add a comment at the top of the file referencing the upstream source: `# Ported from: packages/mjml/test/<filename>`
- If the JS test has multiple `it` blocks, port ALL of them
