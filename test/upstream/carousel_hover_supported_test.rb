# frozen_string_literal: true

# Ported from: packages/mjml/test/carousel-hoverSupported.test.js
require_relative "../test_helper"

class CarouselHoverSupportedTest < Minitest::Test
  def test_thumbnails_supported_renders_display_none
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-carousel thumbnails="supported">
                <mj-carousel-image src="https://placehold.co/450x300/333/ccc/png" />
                <mj-carousel-image src="https://placehold.co/450x300/ccc/000/png" />
                <mj-carousel-image src="https://placehold.co/450x300/f45e43/fff/png" />
              </mj-carousel>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)
    values = doc.css(".mj-carousel-thumbnail").map { |el|
      extract_css_property(el["style"], "display")
    }

    assert_equal ["none", "none", "none"], values
  end
end
