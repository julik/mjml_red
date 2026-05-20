# frozen_string_literal: true

require_relative "../../head_component"
require_relative "../../registry"

module MjmlRed
  module Components
    class MjFont < HeadComponent
      def self.component_name
        "mj-font"
      end

      def self.allowed_attributes
        {"name" => "string", "href" => "string"}
      end

      def handler
        @context[:add].call(:fonts, get_attribute("name"), get_attribute("href"))
      end
    end
  end

  Registry.register(Components::MjFont)
end
