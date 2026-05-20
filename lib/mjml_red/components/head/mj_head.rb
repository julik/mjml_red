# frozen_string_literal: true

require_relative "../../head_component"
require_relative "../../registry"

module MjmlRed
  module Components
    class MjHead < HeadComponent
      def self.component_name
        "mj-head"
      end

      def handler
        handler_children
      end
    end
  end

  Registry.register(Components::MjHead)
end
