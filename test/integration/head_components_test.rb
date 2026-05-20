# frozen_string_literal: true

require_relative "../test_helper"

class HeadComponentsTest < Minitest::Test
  def test_mj_title_sets_document_title
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-title>My Email Title</mj-title>
        </mj-head>
        <mj-body>
          <mj-section><mj-column><mj-text>x</mj-text></mj-column></mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "title", text: "My Email Title"
  end

  def test_mj_preview_adds_hidden_preview_div
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-preview>Preview text here</mj-preview>
        </mj-head>
        <mj-body>
          <mj-section><mj-column><mj-text>x</mj-text></mj-column></mj-section>
        </mj-body>
      </mjml>
    MJML

    style = extract_style(html, "div[style*='max-height:0px']")
    assert style, "Should have hidden preview div"
    assert_includes html, "Preview text here"
  end

  def test_mj_preview_adds_aria_label_when_title_present
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-title>Email Title</mj-title>
        </mj-head>
        <mj-body>
          <mj-section><mj-column><mj-text>x</mj-text></mj-column></mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "div[aria-label='Email Title']"
  end

  def test_mj_font_registers_custom_font
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-font name="Raleway" href="https://fonts.googleapis.com/css?family=Raleway:300,400,500,700" />
        </mj-head>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text font-family="Raleway, sans-serif">Custom font</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "Raleway"
    assert_includes html, "fonts.googleapis.com/css?family=Raleway"
  end

  def test_mj_font_only_imports_used_fonts
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-font name="Raleway" href="https://fonts.googleapis.com/css?family=Raleway:300,400,500,700" />
          <mj-font name="Unused" href="https://fonts.googleapis.com/css?family=Unused:400" />
        </mj-head>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text font-family="Raleway, sans-serif">Custom font</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "family=Raleway"
    refute_includes html, "family=Unused"
  end

  def test_mj_breakpoint_changes_media_query_breakpoint
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-breakpoint width="320px" />
        </mj-head>
        <mj-body>
          <mj-section>
            <mj-column><mj-text>x</mj-text></mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "min-width:320px"
    refute_includes html, "min-width:480px"
  end

  def test_mj_style_inline_adds_to_inline_style
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-style>.block-style { color: blue; }</mj-style>
          <mj-style inline="inline">.inline-style { color: red; }</mj-style>
        </mj-head>
        <mj-body>
          <mj-section><mj-column><mj-text>x</mj-text></mj-column></mj-section>
        </mj-body>
      </mjml>
    MJML

    # Block style should appear in <style> tag
    assert_includes html, ".block-style { color: blue; }"
    # Inline style should not appear in <style> tags — it gets inlined into elements
    refute_includes html, ".inline-style"
  end

  def test_mj_style_inline_applies_css_to_elements
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-style inline="inline">
            .highlight { color: red; font-weight: bold; }
          </mj-style>
        </mj-head>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text css-class="highlight">Styled text</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    doc = Nokogiri::HTML(html)
    highlighted = doc.at_css(".highlight")
    assert highlighted, "Should find element with .highlight class"

    style = highlighted["style"] || ""
    assert_includes style, "color"
    assert_includes style, "red"
    assert_includes style, "font-weight"
    assert_includes style, "bold"
  end

  def test_mj_attributes_with_mj_class
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-attributes>
            <mj-class name="red-text" color="#FF0000" />
          </mj-attributes>
        </mj-head>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text mj-class="red-text">Classed text</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "color:#FF0000"
    assert_includes html, "Classed text"
  end

  def test_mj_html_attributes_applies_to_rendered_elements
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-html-attributes>
            <mj-selector path="table">
              <mj-html-attribute name="data-id">42</mj-html-attribute>
            </mj-selector>
          </mj-html-attributes>
        </mj-head>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text>HTML attributes test</mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "table[data-id='42']"
  end
end
