# frozen_string_literal: true

# Ported from: packages/mjml/test/wrapper-gap.test.js
require_relative "../test_helper"

class WrapperGapTest < Minitest::Test
  def test_renders_correct_gap_values_on_child_sections
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-wrapper gap="20px" css-class="my-wrapper" background-color="#000">
            <mj-section css-class="my-section" background-color="#f45e43" padding="10px">
              <mj-column>
                <mj-text>Section 1</mj-text>
              </mj-column>
            </mj-section>
            <mj-section css-class="my-section" background-color="#ccc" padding="10px">
              <mj-column>
                <mj-text>Section 2</mj-text>
              </mj-column>
            </mj-section>
            <mj-section css-class="my-section" background-color="#333" padding="10px">
              <mj-column>
                <mj-text color="#fff">Section 3</mj-text>
              </mj-column>
            </mj-section>
          </mj-wrapper>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)
    sections = doc.css(".my-section")

    margin_top_values = sections.filter_map { |el|
      style = el["style"]
      next unless style&.include?("margin-top")
      extract_css_property(style, "margin-top")
    }

    assert_equal ["20px", "20px"], margin_top_values
  end
end
