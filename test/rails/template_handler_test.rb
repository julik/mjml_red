# frozen_string_literal: true

require "test_helper"
require "action_view"
require "emjay/rails/template_handler"

class TemplateHandlerTest < Minitest::Test
  def setup
    ActionView::Template.register_template_handler(:mjml, Emjay::Rails::TemplateHandler)
  end

  def test_static_mjml_renders_to_html
    source = <<~MJML
      <mjml><mj-body><mj-section><mj-column><mj-text>Hello World</mj-text></mj-column></mj-section></mj-body></mjml>
    MJML

    html = render_template(source)

    assert_includes html, "<!doctype html>"
    assert_includes html, "Hello World"
    assert_includes html, "<table"
  end

  def test_erb_interpolation_works
    source = <<~MJML
      <mjml><mj-body><mj-section><mj-column><mj-text><%= @greeting %></mj-text></mj-column></mj-section></mj-body></mjml>
    MJML

    html = render_template(source, assigns: {greeting: "Welcome, Alice!"})

    assert_includes html, "Welcome, Alice!"
  end

  def test_output_is_html_safe
    source = <<~MJML
      <mjml><mj-body><mj-section><mj-column><mj-text>Test</mj-text></mj-column></mj-section></mj-body></mjml>
    MJML

    html = render_template(source)

    assert html.html_safe?, "Expected output to be html_safe"
  end

  private

  def render_template(source, assigns: {})
    template = ActionView::Template.new(
      source,
      "test.html.mjml",
      ActionView::Template.registered_template_handler(:mjml),
      format: :html,
      locals: []
    )

    view = ActionView::Base.with_empty_template_cache.new(
      ActionView::LookupContext.new([]),
      assigns.transform_keys(&:to_s),
      nil
    )

    assigns.each do |key, value|
      view.instance_variable_set(:"@#{key}", value)
    end

    template.render(view, {})
  end
end
