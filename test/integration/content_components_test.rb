# frozen_string_literal: true

require_relative "../test_helper"

class MjImageTest < Minitest::Test
  def test_image_renders_img_tag
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-image src="https://example.com/photo.jpg" alt="Photo" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "img[src='https://example.com/photo.jpg']"
    assert_html_has html, "img[alt='Photo']"
  end

  def test_image_with_link
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-image src="https://example.com/photo.jpg" href="https://example.com" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "a[href='https://example.com'] img"
    assert_html_has html, "a[target='_blank']"
  end

  def test_image_without_link
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-image src="https://example.com/photo.jpg" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    refute_html_has html, "a img"
  end

  def test_image_width_capped_by_container
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-image src="https://example.com/photo.jpg" width="800px" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    # Column box width is 550px (600 - 25*2 padding), so image width should be capped at 550
    assert_html_has html, "img[width='550']"
  end

  def test_image_fluid_on_mobile
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-image src="https://example.com/photo.jpg" fluid-on-mobile="true" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "table.mj-full-width-mobile"
    assert_html_has html, "td.mj-full-width-mobile"
    assert_includes html, "mj-full-width-mobile"
  end

  def test_image_head_style_for_fluid
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-image src="https://example.com/photo.jpg" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    # Image always adds fluid-on-mobile media query
    assert_includes html, "mj-full-width-mobile"
    assert_includes html, "max-width:479px"
  end

  def test_image_custom_height
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-image src="https://example.com/photo.jpg" height="200px" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "img[height='200']"
  end
end

class MjButtonTest < Minitest::Test
  def test_button_renders_link
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-button href="https://example.com">Click me</mj-button>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "a[href='https://example.com']", text: "Click me"
    assert_html_has html, "a[target='_blank']"
  end

  def test_button_without_href_uses_p_tag
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-button>No link</mj-button>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    refute_html_has html, "a"
    # Uses <p> tag when no href
    doc = Nokogiri::HTML(html)
    p_tags = doc.css("td[role='presentation'] p")
    assert p_tags.any? { |p| p.text.strip == "No link" }, "Expected <p> tag with 'No link' text"
  end

  def test_button_custom_colors
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-button href="#" background-color="#ff0000" color="#00ff00">Colored</mj-button>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "#ff0000"
    assert_includes html, "#00ff00"
  end

  def test_button_border_radius
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-button href="#" border-radius="10px">Rounded</mj-button>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "border-radius:10px"
  end
end

class MjDividerTest < Minitest::Test
  def test_divider_renders_border
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-divider />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "border-top:solid 4px #000000"
    assert_html_has html, "p"
  end

  def test_divider_custom_style
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-divider border-color="#ff0000" border-width="2px" border-style="dashed" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "border-top:dashed 2px #ff0000"
  end

  def test_divider_outlook_table
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-divider />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_match(/<!--\[if mso \| IE\]>.*<table/, html)
  end

  def test_divider_width_percentage
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-divider width="50%" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "width:50%"
  end
end

class MjSpacerTest < Minitest::Test
  def test_spacer_renders_div
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-spacer height="40px" />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "height:40px"
    assert_includes html, "line-height:40px"
    assert_includes html, "&#8202;"
  end

  def test_spacer_default_height
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-spacer />
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "height:20px"
  end
end

class MjTableTest < Minitest::Test
  def test_table_renders_content
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-table>
                <tr>
                  <td>Cell 1</td>
                  <td>Cell 2</td>
                </tr>
              </mj-table>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "Cell 1"
    assert_includes html, "Cell 2"
  end

  def test_table_default_styles
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-table>
                <tr><td>X</td></tr>
              </mj-table>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "font-family:Ubuntu, Helvetica, Arial, sans-serif"
    assert_includes html, "font-size:13px"
    assert_includes html, "line-height:22px"
  end
end

class MjRawTest < Minitest::Test
  def test_raw_passes_through_html
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-raw>
                <div class="custom">Raw content</div>
              </mj-raw>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_html_has html, "div.custom", text: "Raw content"
  end

  def test_raw_preserves_html_as_is
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-raw>
                <span style="color:red;">Styled</span>
              </mj-raw>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "color:red;"
    assert_includes html, "Styled"
  end
end
