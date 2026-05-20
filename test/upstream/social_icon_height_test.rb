# frozen_string_literal: true

# Ported from: packages/mjml/test/social-icon-height.test.js
require_relative "../test_helper"

class SocialIconHeightTest < Minitest::Test
  def test_renders_correct_icon_height_on_social
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column css-class="my-social-element">
              <mj-social icon-height="40px">
                <mj-social-element name="facebook" href="https://mjml.io/" css-class="my-social-element">
                  Facebook
                </mj-social-element>
              </mj-social>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)

    # Height in style should be 40px
    icon_tds = doc.css(".my-social-element > td > table > tbody > tr > td")
    height_values = icon_tds.map { |td| extract_css_property(td["style"], "height") }.compact
    assert_includes height_values, "40px"

    # img should NOT have a height attribute
    imgs = doc.css(".my-social-element > td > table > tbody > tr > td img")
    imgs.each do |img|
      assert_nil img["height"], "img should not have height attribute"
    end
  end
end
