# frozen_string_literal: true

# Ported from: packages/mjml/test/accordion-padding.test.js
require_relative "../test_helper"

class AccordionPaddingTest < Minitest::Test
  def test_renders_correct_padding_on_accordion_title_and_text
    html = render(<<~MJML)
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

    doc = parse_doc(html)
    tds = doc.css(".mj-accordion-title td:first-child, .mj-accordion-content td:first-child")

    %w[padding-left padding-right padding-top padding-bottom].each do |prop|
      values = tds.map { |td| extract_css_property(td["style"], prop) }
      assert_equal ["40px", "40px"], values, "#{prop} on accordion-title and accordion-text"
    end
  end
end
