# frozen_string_literal: true

# Ported from: packages/mjml/test/border-radius-string.test.js
require_relative "../test_helper"

class BorderRadiusStringTest < Minitest::Test
  BORDER_RADIUS_VALUES = [
    "10px",
    "10% 20%",
    "10px 20px 30px",
    "10px 20% 30px 40%",
    "100px 50px 100px 50px / 50px 50px 50px 50px"
  ].freeze

  def test_mj_button_border_radius
    buttons = BORDER_RADIUS_VALUES.map { |v| %(<mj-button border-radius="#{v}">Button</mj-button>) }.join
    html = render_in_column(buttons)
    assert_contains_all_border_radius_values(html, "mj-button")
  end

  def test_mj_image_border_radius
    images = BORDER_RADIUS_VALUES.map { |v| %(<mj-image src="https://example.com/img.png" border-radius="#{v}" />) }.join
    html = render_in_column(images)
    assert_contains_all_border_radius_values(html, "mj-image")
  end

  def test_mj_hero_border_radius
    heroes = BORDER_RADIUS_VALUES.map { |v|
      %(<mj-hero border-radius="#{v}" background-color="#eee"><mj-text>Hero</mj-text></mj-hero>)
    }.join
    html = render(<<~MJML)
      <mjml><mj-body>#{heroes}</mj-body></mjml>
    MJML
    assert_contains_all_border_radius_values(html, "mj-hero")
  end

  def test_mj_section_and_column_border_radius
    sections = BORDER_RADIUS_VALUES.map { |v|
      %(<mj-section border-radius="#{v}"><mj-column border-radius="#{v}" padding="20px"><mj-text>Text</mj-text></mj-column></mj-section>)
    }.join
    html = render(<<~MJML)
      <mjml><mj-body>#{sections}</mj-body></mjml>
    MJML
    assert_contains_all_border_radius_values(html, "mj-section/mj-column")
  end

  def test_mj_column_inner_border_radius
    sections = BORDER_RADIUS_VALUES.map { |v|
      %(<mj-section><mj-column border-radius="0px" inner-border-radius="#{v}" padding="20px"><mj-text>Text</mj-text></mj-column></mj-section>)
    }.join
    html = render(<<~MJML)
      <mjml><mj-body>#{sections}</mj-body></mjml>
    MJML
    assert_contains_all_border_radius_values(html, "mj-column inner-border-radius")
  end

  def test_mj_social_border_radius
    socials = BORDER_RADIUS_VALUES.map { |v|
      %(<mj-social border-radius="#{v}"><mj-social-element name="facebook" href="#" border-radius="#{v}">FB</mj-social-element></mj-social>)
    }.join
    html = render_in_column(socials)
    assert_contains_all_border_radius_values(html, "mj-social")
  end

  def test_mj_carousel_border_radius
    carousels = BORDER_RADIUS_VALUES.map { |v|
      %(<mj-carousel border-radius="#{v}"><mj-carousel-image src="https://example.com/1.png" border-radius="#{v}" /><mj-carousel-image src="https://example.com/2.png" border-radius="#{v}" /></mj-carousel>)
    }.join
    html = render_in_column(carousels)
    assert_contains_all_border_radius_values(html, "mj-carousel")
  end

  private

  def render_in_column(content)
    render(<<~MJML)
      <mjml><mj-body><mj-section><mj-column>#{content}</mj-column></mj-section></mj-body></mjml>
    MJML
  end

  def assert_contains_all_border_radius_values(html, label)
    found = extract_all_border_radius_values(html)
    BORDER_RADIUS_VALUES.each do |v|
      assert_includes found, v, "#{label} should include border-radius value: #{v}"
    end
  end

  def extract_all_border_radius_values(html)
    doc = parse_doc(html)
    values = doc.css("[style]").filter_map { |el|
      style = el["style"]
      next unless style&.include?("border-radius")
      extract_css_property(style, "border-radius")
    }
    values.uniq
  end
end
