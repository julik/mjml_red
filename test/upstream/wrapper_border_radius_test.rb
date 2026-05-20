# frozen_string_literal: true

# Ported from: packages/mjml/test/wrapper-border-radius.test.js
require_relative "../test_helper"

class WrapperBorderRadiusTest < Minitest::Test
  def test_renders_correct_border_radius_on_wrapper
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-wrapper border="1px solid red" border-radius="10px">
            <mj-section>
              <mj-column>
                <mj-text font-size="20px" color="#F45E43" font-family="helvetica">Hello World</mj-text>
              </mj-column>
            </mj-section>
          </mj-wrapper>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)

    # border-radius on td and div
    elements = doc.css("body > div > div > table:first-child > tbody > tr > td, body > div > div")
    border_radius_values = elements.map { |el| extract_css_property(el["style"], "border-radius") }
    assert_equal ["10px", "10px"], border_radius_values

    # overflow: hidden on wrapper div
    wrapper_divs = doc.css("body > div > div")
    overflow_values = wrapper_divs.map { |el| extract_css_property(el["style"], "overflow") }
    assert_equal ["hidden"], overflow_values

    # border-collapse: separate on wrapper table
    wrapper_tables = doc.css("body > div > div > table:first-child")
    collapse_values = wrapper_tables.map { |el| extract_css_property(el["style"], "border-collapse") }
    assert_equal ["separate"], collapse_values
  end
end
