# frozen_string_literal: true

require_relative "../test_helper"

class AdvancedComponentsTest < Minitest::Test
  # --- mj-hero ---

  def test_hero_renders_background_image
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-hero background-url="https://example.com/bg.jpg" background-color="#333">
            <mj-text>Hero text</mj-text>
          </mj-hero>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "Hero text"
    assert_includes html, "url('https://example.com/bg.jpg')"
    assert_includes html, "v:image"
    assert_includes html, "background:#333"
  end

  def test_hero_fixed_height_mode
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-hero mode="fixed-height" height="500px" background-height="469px" background-width="600px" padding="0px">
            <mj-text>Fixed</mj-text>
          </mj-hero>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, 'height="500"'
    assert_includes html, "height:500px"
  end

  def test_hero_fluid_height_mode
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-hero mode="fluid-height" background-width="600px" background-height="300px">
            <mj-text>Fluid</mj-text>
          </mj-hero>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "Fluid"
    assert_includes html, "padding-bottom:50%"
  end

  # --- mj-social ---

  def test_social_renders_icons
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-social>
                <mj-social-element name="facebook" href="https://facebook.com/test">FB</mj-social-element>
              </mj-social>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "ico-social/facebook.png"
    assert_includes html, "facebook.com/sharer"
    assert_includes html, "FB"
    assert_includes html, "background:#3b5998"
  end

  def test_social_vertical_mode
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-social mode="vertical">
                <mj-social-element name="twitter" href="https://twitter.com/test">Twitter</mj-social-element>
              </mj-social>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    # Vertical mode uses a single table, not inline-table
    refute_includes html, "inline-table"
  end

  def test_social_horizontal_mode
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-social mode="horizontal">
                <mj-social-element name="twitter" href="https://twitter.com/test">T</mj-social-element>
                <mj-social-element name="facebook" href="https://facebook.com/test">F</mj-social-element>
              </mj-social>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "inline-table"
    assert_includes html, "mso | IE]></td><td>"
  end

  # --- mj-navbar ---

  def test_navbar_renders_links
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-navbar>
                <mj-navbar-link href="/home">Home</mj-navbar-link>
                <mj-navbar-link href="/about">About</mj-navbar-link>
              </mj-navbar>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, 'href="/home"'
    assert_includes html, "Home"
    assert_includes html, 'href="/about"'
    assert_includes html, "About"
    assert_includes html, "mj-inline-links"
  end

  def test_navbar_hamburger_mode
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-navbar hamburger="hamburger">
                <mj-navbar-link href="/home">Home</mj-navbar-link>
              </mj-navbar>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "mj-menu-checkbox"
    assert_includes html, "mj-menu-trigger"
    assert_includes html, "&#9776;"
    assert_includes html, "&#8855;"
  end

  def test_navbar_head_style
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-navbar hamburger="hamburger">
                <mj-navbar-link href="/home">Home</mj-navbar-link>
              </mj-navbar>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "noinput.mj-menu-checkbox"
    assert_includes html, "mj-menu-checkbox[type=\"checkbox\"]"
  end

  def test_navbar_base_url
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-navbar base-url="https://example.com">
                <mj-navbar-link href="/page">Page</mj-navbar-link>
              </mj-navbar>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, 'href="https://example.com/page"'
  end

  # --- mj-accordion ---

  def test_accordion_renders_elements
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-accordion>
                <mj-accordion-element>
                  <mj-accordion-title>Title 1</mj-accordion-title>
                  <mj-accordion-text>Content 1</mj-accordion-text>
                </mj-accordion-element>
              </mj-accordion>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "Title 1"
    assert_includes html, "Content 1"
    assert_includes html, "mj-accordion-element"
    assert_includes html, "mj-accordion-checkbox"
  end

  def test_accordion_head_style
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-accordion>
                <mj-accordion-element>
                  <mj-accordion-title>T</mj-accordion-title>
                  <mj-accordion-text>C</mj-accordion-text>
                </mj-accordion-element>
              </mj-accordion>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "mj-accordion-checkbox"
    assert_includes html, "noinput.mj-accordion-checkbox"
  end

  def test_accordion_default_children
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-accordion>
                <mj-accordion-element>
                </mj-accordion-element>
              </mj-accordion>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    # Should still render title and text containers even without explicit children
    assert_includes html, "mj-accordion-title"
    assert_includes html, "mj-accordion-content"
  end

  # --- mj-carousel ---

  def test_carousel_renders_images
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-carousel>
                <mj-carousel-image src="https://example.com/1.png" />
                <mj-carousel-image src="https://example.com/2.png" />
              </mj-carousel>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "mj-carousel"
    assert_includes html, "https://example.com/1.png"
    assert_includes html, "https://example.com/2.png"
    assert_includes html, "mj-carousel-image-1"
    assert_includes html, "mj-carousel-image-2"
  end

  def test_carousel_generates_radios
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-carousel>
                <mj-carousel-image src="https://example.com/1.png" />
                <mj-carousel-image src="https://example.com/2.png" />
              </mj-carousel>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, 'type="radio"'
    assert_includes html, 'checked="checked"'
    assert_includes html, "mj-carousel-radio"
  end

  def test_carousel_generates_controls
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-carousel>
                <mj-carousel-image src="https://example.com/1.png" />
                <mj-carousel-image src="https://example.com/2.png" />
              </mj-carousel>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "mj-carousel-previous"
    assert_includes html, "mj-carousel-next"
  end

  def test_carousel_generates_thumbnails
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-carousel thumbnails="visible">
                <mj-carousel-image src="https://example.com/1.png" />
                <mj-carousel-image src="https://example.com/2.png" />
              </mj-carousel>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "mj-carousel-thumbnail"
  end

  def test_carousel_head_style
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-carousel>
                <mj-carousel-image src="https://example.com/1.png" />
                <mj-carousel-image src="https://example.com/2.png" />
              </mj-carousel>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_includes html, "-webkit-user-select: none"
    assert_includes html, "mj-carousel-radio"
    assert_includes html, "display: none !important"
  end

  def test_carousel_fallback_for_mso
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-carousel>
                <mj-carousel-image src="https://example.com/1.png" />
                <mj-carousel-image src="https://example.com/2.png" />
              </mj-carousel>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    # MSO fallback renders only first image
    assert_includes html, "<!--[if mso]>"
    # First image should be in the fallback
    assert_match(/\[if mso\]>.*example\.com\/1\.png.*<!\[endif\]/m, html)
  end
end
