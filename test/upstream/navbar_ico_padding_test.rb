# frozen_string_literal: true

# Ported from: packages/mjml/test/navbar-ico-padding.test.js
require_relative "../test_helper"

class NavbarIcoPaddingTest < Minitest::Test
  def test_renders_correct_padding_on_navbar_hamburger_icon
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-navbar hamburger="hamburger" ico-padding="20px" ico-padding-bottom="20px" ico-padding-left="30px" ico-padding-right="40px" ico-padding-top="50px">
                <mj-navbar-link href="/getting-started" color="#ffffff">Getting started</mj-navbar-link>
                <mj-navbar-link href="/try-it-live" color="#ffffff">Try it live</mj-navbar-link>
              </mj-navbar>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)
    labels = doc.css(".mj-menu-label")

    {
      "padding-bottom" => "20px",
      "padding-left" => "30px",
      "padding-right" => "40px",
      "padding-top" => "50px"
    }.each do |prop, expected|
      values = labels.map { |el| extract_css_property(el["style"], prop) }
      assert_equal [expected], values, "#{prop} on navbar hamburger icon"
    end
  end
end
