# frozen_string_literal: true

module Emjay
  class Railtie < Rails::Railtie
    initializer "emjay.register_template_handler" do
      ActiveSupport.on_load(:action_view) do
        require "emjay/rails/template_handler"
        ActionView::Template.register_template_handler(:mjml, Emjay::Rails::TemplateHandler)
      end
    end
  end
end
