# frozen_string_literal: true

# Ported from: packages/mjml/test/table-cellspacing.test.js
require_relative "../test_helper"

class TableCellspacingTest < Minitest::Test
  def test_renders_correct_cellspacing_and_border_collapse
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-table border="1px solid #000" width="auto" cellpadding="20" cellspacing="10" css-class="my-table">
                <tr style="border-bottom:1px solid #000;text-align:left;">
                  <th style="background:#ddd;">Year</th>
                  <th style="background:#ddd;">Language</th>
                </tr>
                <tr>
                  <td style="background:#ddd;">1995</td>
                  <td style="background:#ddd;">PHP</td>
                </tr>
              </mj-table>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)
    tables = doc.css(".my-table > table")

    cellspacing_values = tables.map { |el| el["cellspacing"] }
    assert_equal ["10"], cellspacing_values

    border_collapse_values = tables.map { |el| extract_css_property(el["style"], "border-collapse") }
    assert_equal ["separate"], border_collapse_values
  end
end
