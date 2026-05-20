# frozen_string_literal: true

require "test_helper"
require "action_view"
require "action_mailer"
require "mail"
require "emjay/rails/template_handler"
require "emjay/rails/mail_interceptor"

module TemplateRenderHelper
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

class TemplateHandlerTest < Minitest::Test
  include TemplateRenderHelper

  def setup
    ActionView::Template.register_template_handler(:mjml, Emjay::Rails::TemplateHandler)
  end

  def test_handler_returns_mjml_not_html
    source = <<~MJML
      <mjml><mj-body><mj-section><mj-column><mj-text>Hello World</mj-text></mj-column></mj-section></mj-body></mjml>
    MJML

    result = render_template(source)

    assert_includes result, "<mjml>"
    assert_includes result, "Hello World"
    refute_includes result, "<!doctype html>"
  end

  def test_erb_interpolation_works
    source = <<~MJML
      <mjml><mj-body><mj-section><mj-column><mj-text><%= @greeting %></mj-text></mj-column></mj-section></mj-body></mjml>
    MJML

    result = render_template(source, assigns: {greeting: "Welcome, Alice!"})

    assert_includes result, "Welcome, Alice!"
    assert_includes result, "<mjml>"
  end
end

class MailInterceptorTest < Minitest::Test
  def test_compiles_mjml_in_html_part
    message = Mail::Message.new
    message.content_type = "text/html"
    message.body = "<mjml><mj-body><mj-section><mj-column><mj-text>Hello</mj-text></mj-column></mj-section></mj-body></mjml>"

    Emjay::Rails::MailInterceptor.delivering_email(message)

    assert_includes message.body.decoded, "<!doctype html>"
    assert_includes message.body.decoded, "Hello"
    assert_includes message.body.decoded, "<table"
  end

  def test_compiles_mjml_in_multipart_message
    message = Mail::Message.new
    message.html_part = Mail::Part.new(
      content_type: "text/html",
      body: "<mjml><mj-body><mj-section><mj-column><mj-text>Multipart</mj-text></mj-column></mj-section></mj-body></mjml>"
    )
    message.text_part = Mail::Part.new(
      content_type: "text/plain",
      body: "Plain text fallback"
    )

    Emjay::Rails::MailInterceptor.delivering_email(message)

    assert_includes message.html_part.body.decoded, "<!doctype html>"
    assert_includes message.html_part.body.decoded, "Multipart"
    assert_equal "Plain text fallback", message.text_part.body.decoded
  end

  def test_non_mjml_email_passes_through
    original_body = "<html><body>Regular HTML</body></html>"
    message = Mail::Message.new
    message.content_type = "text/html"
    message.body = original_body

    Emjay::Rails::MailInterceptor.delivering_email(message)

    assert_equal original_body, message.body.decoded
  end

  def test_previewing_email_also_compiles
    message = Mail::Message.new
    message.content_type = "text/html"
    message.body = "<mjml><mj-body><mj-section><mj-column><mj-text>Preview</mj-text></mj-column></mj-section></mj-body></mjml>"

    Emjay::Rails::MailInterceptor.previewing_email(message)

    assert_includes message.body.decoded, "<!doctype html>"
    assert_includes message.body.decoded, "Preview"
  end
end

class TemplateHandlerInterceptorIntegrationTest < Minitest::Test
  include TemplateRenderHelper

  def setup
    ActionView::Template.register_template_handler(:mjml, Emjay::Rails::TemplateHandler)
  end

  def test_end_to_end_erb_and_interceptor
    source = <<~MJML
      <mjml><mj-body><mj-section><mj-column><mj-text><%= @name %></mj-text></mj-column></mj-section></mj-body></mjml>
    MJML

    mjml_output = render_template(source, assigns: {name: "Integration Test"})

    # Simulate what ActionMailer does: put the rendered MJML into a message
    message = Mail::Message.new
    message.content_type = "text/html"
    message.body = mjml_output

    Emjay::Rails::MailInterceptor.delivering_email(message)

    assert_includes message.body.decoded, "<!doctype html>"
    assert_includes message.body.decoded, "Integration Test"
    assert_includes message.body.decoded, "<table"
  end
end
