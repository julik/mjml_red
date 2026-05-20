# frozen_string_literal: true

module Emjay
  module Rails
    class MailInterceptor
      MJML_TAG_PATTERN = /<mjml[\s>]/i

      def self.delivering_email(message)
        new.compile_mjml!(message)
      end

      def self.previewing_email(message)
        new.compile_mjml!(message)
      end

      def compile_mjml!(message)
        if message.multipart?
          message.parts.each { |part| compile_part!(part) }
        else
          compile_part!(message)
        end
      end

      private

      def compile_part!(part)
        return if part.multipart?
        return unless part.content_type&.include?("text/html") || part.content_type.nil?

        body = part.body.decoded
        return unless MJML_TAG_PATTERN.match?(body)

        part.body = Emjay.to_html(body)
      end
    end
  end
end
