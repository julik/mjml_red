# frozen_string_literal: true

module MjmlRed
  class Railtie < Rails::Railtie
    initializer "mjml_red.register_template_handler" do
      ActiveSupport.on_load(:action_view) do
        require "mjml_red/rails/template_handler"
        ActionView::Template.register_template_handler(:mjml, MjmlRed::Rails::TemplateHandler)
      end
    end
  end
end
