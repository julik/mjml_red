# frozen_string_literal: true

require_relative "../test_helper"

class BasicRenderTest < Minitest::Test
  def test_renders_basic_mjml_document
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text>Hello World</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "<!doctype html>"
    assert_includes html, "Hello World"

    assert_html_has html, "body"
    assert_html_has html, "div[role='article']",
      attrs: {lang: "und", dir: "auto", "aria-roledescription": "email"}
    assert_html_has html, "table[role='presentation']"
  end

  def test_column_classes_and_media_queries
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text>Hello World</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "div.mj-column-per-100"
    assert_html_has html, "div.mj-outlook-group-fix"
    assert_includes html, "@media only screen and (min-width:480px)"
    assert_includes html, ".mj-column-per-100 { width:100%"
  end

  def test_renders_with_head_styles
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-style>
            .custom { color: red; }
          </mj-style>
        </mj-head>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text>Styled</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, ".custom { color: red; }"
    assert_includes html, "Styled"
  end

  def test_renders_with_default_attributes
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-attributes>
            <mj-text color="#FF0000" />
          </mj-attributes>
        </mj-head>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text>Red text</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    style = extract_style(html, "div[style*='color:#FF0000']")
    assert style, "Should have element with red color"
    assert_equal "#FF0000", extract_css_property(style, "color")
  end

  def test_renders_responsive_column_widths
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text>Col 1</mj-text>
            </mj-column>
            <mj-column>
              <mj-text>Col 2</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_equal 2, count_html_nodes(html, "div.mj-outlook-group-fix"),
      "Should have two column divs"
    assert_html_has html, "div.mj-column-per-50"
    assert_includes html, "Col 1"
    assert_includes html, "Col 2"
  end

  def test_text_inline_styles
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text font-size="20px" color="#F45E43" font-family="helvetica">
                Hello World
              </mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    style = extract_style(html, "div[style*='font-family:helvetica']")
    assert style, "Should have text div with custom font"
    assert_equal "20px", extract_css_property(style, "font-size")
    assert_equal "#F45E43", extract_css_property(style, "color")
    assert_equal "helvetica", extract_css_property(style, "font-family")
  end

  def test_outlook_conditionals_are_minified_and_merged
    html = render("<mjml><mj-body><mj-section><mj-column><mj-text>Test</mj-text></mj-column></mj-section></mj-body></mjml>")

    # Minified: no multi-line content inside conditional blocks
    assert_match(/<!--\[if mso \| IE\]><table[^>]*>/, html,
      "Outlook conditional table should be on one line")

    # Merged: no adjacent endif/if pairs
    refute_match(/<!\[endif\]-->\s*<!--\[if mso \| IE\]>/, html,
      "Adjacent Outlook conditionals should be merged")
  end
end
