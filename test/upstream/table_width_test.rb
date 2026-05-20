# frozen_string_literal: true

# Ported from: packages/mjml/test/tableWidth.test.js
require_relative "../test_helper"

class TableWidthTest < Minitest::Test
  def test_renders_correct_width_on_tables
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-wrapper>
            <mj-section>
              <mj-column>
                <mj-table css-class="table">
                  <tr><th>Default Width</th><td>100%</td></tr>
                </mj-table>
              </mj-column>
            </mj-section>
            <mj-section>
              <mj-column>
                <mj-table width="500px" css-class="table">
                  <tr><th>Pixel Width</th><td>500px</td></tr>
                </mj-table>
              </mj-column>
            </mj-section>
            <mj-section>
              <mj-column>
                <mj-table width="80%" css-class="table">
                  <tr><th>Percentage Width</th><td>80%</td></tr>
                </mj-table>
              </mj-column>
            </mj-section>
            <mj-section>
              <mj-column>
                <mj-table width="auto" css-class="table">
                  <tr><th>Auto Width</th><td>Auto</td></tr>
                </mj-table>
              </mj-column>
            </mj-section>
          </mj-wrapper>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)
    tables = doc.css(".table table")

    width_attrs = tables.map { |el| el["width"] }
    assert_equal ["100%", "500", "80%", "auto"], width_attrs

    width_styles = tables.map { |el| extract_css_property(el["style"], "width") }
    assert_equal ["100%", "500px", "80%", "auto"], width_styles
  end
end
