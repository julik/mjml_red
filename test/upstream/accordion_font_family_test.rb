# frozen_string_literal: true

# Ported from: packages/mjml/test/accordion-fontFamily.test.js
require_relative "../test_helper"

class AccordionFontFamilyTest < Minitest::Test
  def test_renders_correct_font_family_on_accordion_title_and_text
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-accordion css-class="my-accordion-1" font-family="serif">
                <mj-accordion-element>
                  <mj-accordion-title>Why use an accordion?</mj-accordion-title>
                  <mj-accordion-text>Because it is useful.</mj-accordion-text>
                </mj-accordion-element>
              </mj-accordion>
            </mj-column>
          </mj-section>
          <mj-section>
            <mj-column>
              <mj-accordion css-class="my-accordion-2" font-family="serif">
                <mj-accordion-element font-family="sans-serif">
                  <mj-accordion-title font-family="monospace">Why use an accordion?</mj-accordion-title>
                  <mj-accordion-text font-family="monospace">Because it is useful.</mj-accordion-text>
                </mj-accordion-element>
              </mj-accordion>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)

    values = doc.css(
      ".my-accordion-1 .mj-accordion-title td:first-child, " \
      ".my-accordion-1 .mj-accordion-content td:first-child, " \
      ".my-accordion-2 .mj-accordion-title td:first-child, " \
      ".my-accordion-2 .mj-accordion-content td:first-child"
    ).map { |td| extract_css_property(td["style"], "font-family") }

    assert_equal ["serif", "serif", "monospace", "monospace"], values
  end
end
