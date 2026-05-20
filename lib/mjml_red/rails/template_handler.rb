# frozen_string_literal: true

module MjmlRed
  module Rails
    module TemplateHandler
      def self.call(template, source)
        erb_handler = ActionView::Template.registered_template_handler(:erb)
        compiled_erb = erb_handler.call(template, source)
        "MjmlRed.to_html((begin;#{compiled_erb};end).to_s).html_safe"
      end
    end
  end
end
