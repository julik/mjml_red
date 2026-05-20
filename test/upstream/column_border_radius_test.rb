# frozen_string_literal: true

# Ported from: packages/mjml/test/column-border-radius.test.js
require_relative "../test_helper"

class ColumnBorderRadiusTest < Minitest::Test
  def test_renders_correct_border_radius_and_border_collapse
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column border-radius="50px" inner-border-radius="40px" padding="50px" border="5px solid #000" inner-border="5px solid #666">
              <mj-text>Hello World</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)
    elements = doc.css(
      ".mj-column-per-100 > table > tbody > tr > td, " \
      ".mj-column-per-100 > table > tbody > tr > td > table"
    )

    border_radius_values = elements.map { |el| extract_css_property(el["style"], "border-radius") }
    assert_equal ["50px", "40px"], border_radius_values

    border_collapse_values = elements.map { |el| extract_css_property(el["style"], "border-collapse") }
    assert_equal ["separate", "separate"], border_collapse_values
  end
end
