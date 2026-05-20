# frozen_string_literal: true

# Ported from: packages/mjml/test/social-align.test.js
require_relative "../test_helper"

class SocialAlignTest < Minitest::Test
  def test_renders_correct_align_on_social_element
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-social mode="vertical">
                <mj-social-element name="facebook" href="https://mjml.io/" icon-position="right" align="right" css-class="my-social-element">
                  Facebook
                </mj-social-element>
              </mj-social>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)
    values = doc.css(".my-social-element > td:first-child").map { |td|
      extract_css_property(td["style"], "text-align")
    }

    assert_equal ["right"], values
  end
end
