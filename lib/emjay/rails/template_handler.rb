# frozen_string_literal: true

module Emjay
  module Rails
    module TemplateHandler
      def self.call(template, source)
        # Always chain through ERB so that <%= %> tags work in .html.mjml templates.
        # Rails only dispatches on the rightmost extension, so there is no way to use
        # .html.mjml.erb — our handler must invoke ERB explicitly. Running ERB on a
        # template with no ERB tags is a no-op. This matches the convention used by
        # mjml-rails, Haml, Slim, and similar gems.
        erb_handler = ActionView::Template.registered_template_handler(:erb)
        compiled_erb = erb_handler.call(template, source)
        "Emjay.to_html((begin;#{compiled_erb};end).to_s).html_safe"
      end
    end
  end
end
