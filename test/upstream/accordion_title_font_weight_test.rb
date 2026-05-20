# frozen_string_literal: true

# Ported from: packages/mjml/test/accordionTitle-fontWeight.test.js
require_relative "../test_helper"

class AccordionTitleFontWeightTest < Minitest::Test
  def test_renders_correct_font_weight_on_accordion_title
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-attributes>
            <mj-accordion border="none" padding="1px" />
            <mj-accordion-element icon-wrapped-url="https://i.imgur.com/Xvw0vjq.png" icon-unwrapped-url="https://i.imgur.com/KKHenWa.png" icon-height="24px" icon-width="24px" />
            <mj-accordion-title font-family="Roboto, Open Sans, Helvetica, Arial, sans-serif" background-color="#fff" color="#031017" padding="15px" font-size="18px" />
            <mj-accordion-text font-family="Open Sans, Helvetica, Arial, sans-serif" background-color="#fafafa" padding="15px" color="#505050" font-size="14px" />
          </mj-attributes>
        </mj-head>
        <mj-body>
          <mj-section padding="20px" background-color="#ffffff">
            <mj-column background-color="#dededd">
              <mj-accordion>
                <mj-accordion-element>
                  <mj-accordion-title font-weight="bold" css-class="accordion-title">Why use an accordion?</mj-accordion-title>
                  <mj-accordion-text font-weight="bold">Content 1</mj-accordion-text>
                </mj-accordion-element>
                <mj-accordion-element>
                  <mj-accordion-title font-weight="700" css-class="accordion-title">How it works</mj-accordion-title>
                  <mj-accordion-text font-weight="700">Content 2</mj-accordion-text>
                </mj-accordion-element>
              </mj-accordion>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)
    values = doc.css(".accordion-title").map { |el|
      extract_css_property(el["style"], "font-weight")
    }

    assert_equal ["bold", "700"], values
  end
end
