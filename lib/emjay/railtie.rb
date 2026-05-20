# frozen_string_literal: true

module Emjay
  class Railtie < Rails::Railtie
    initializer "emjay.register_template_handler_and_interceptor" do
      ActiveSupport.on_load(:action_mailer) do
        require "emjay/rails/template_handler"
        ActionView::Template.register_template_handler(:mjml, Emjay::Rails::TemplateHandler)

        require "emjay/rails/mail_interceptor"
        interceptor = Emjay::Rails::MailInterceptor
        ActionMailer::Base.register_interceptor(interceptor)
        ActionMailer::Base.register_preview_interceptor(interceptor)
      end
    end
  end
end
