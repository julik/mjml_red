# frozen_string_literal: true

require_relative "../../head_component"
require_relative "../../registry"

module MjmlRed
  module Components
    class MjPreview < HeadComponent
      def self.component_name
        "mj-preview"
      end

      def self.ending_tag?
        true
      end

      def handler
        @context[:add].call(:preview, get_content)
      end
    end
  end

  Registry.register(Components::MjPreview)
end
