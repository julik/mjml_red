# frozen_string_literal: true

require_relative "../test_helper"

class MjWrapperTest < Minitest::Test
  def test_wrapper_wraps_sections
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-wrapper background-color="#f0f0f0">
            <mj-section>
              <mj-column>
                <mj-text>Inside wrapper</mj-text>
              </mj-column>
            </mj-section>
          </mj-wrapper>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "Inside wrapper"
    assert_includes html, "#f0f0f0"
    # Wrapper renders each child section in its own outlook tr/td
    assert_match(/<!--\[if mso \| IE\]>.*<tr>/, html)
  end

  def test_wrapper_full_width
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-wrapper full-width="full-width" background-color="#ff0000">
            <mj-section>
              <mj-column>
                <mj-text>Full width</mj-text>
              </mj-column>
            </mj-section>
          </mj-wrapper>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "Full width"
    # Full-width wrapper uses a table with width:100%
    assert_html_has html, "table[style*='width:100%']"
  end

  def test_wrapper_with_gap_passes_gap_to_sections
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-wrapper gap="20px">
            <mj-section>
              <mj-column>
                <mj-text>Section 1</mj-text>
              </mj-column>
            </mj-section>
            <mj-section>
              <mj-column>
                <mj-text>Section 2</mj-text>
              </mj-column>
            </mj-section>
          </mj-wrapper>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "Section 1"
    assert_includes html, "Section 2"
  end
end

class MjGroupTest < Minitest::Test
  def test_group_renders_columns
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-group>
              <mj-column>
                <mj-text>Column 1</mj-text>
              </mj-column>
              <mj-column>
                <mj-text>Column 2</mj-text>
              </mj-column>
            </mj-group>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "Column 1"
    assert_includes html, "Column 2"
    assert_html_has html, "div.mj-outlook-group-fix"
  end

  def test_group_generates_column_class
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-group>
              <mj-column>
                <mj-text>A</mj-text>
              </mj-column>
              <mj-column>
                <mj-text>B</mj-text>
              </mj-column>
            </mj-group>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    # Group itself gets a column class based on its width relative to the section
    assert_includes html, "mj-column-per-100"
  end

  def test_group_with_background_color
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-group background-color="#eeeeee">
              <mj-column>
                <mj-text>Colored group</mj-text>
              </mj-column>
            </mj-group>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "#eeeeee"
    assert_includes html, "Colored group"
  end
end
