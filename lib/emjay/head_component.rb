# frozen_string_literal: true

require_relative "component"

module Emjay
  # Base class for head components. Port of JS HeadComponent from createComponent.js.
  class HeadComponent < Component
    def handler
      # Subclasses override
    end

    def handler_children
      children = @props[:children] || []
      components = @context[:components] || {}

      children.filter_map do |child|
        component_class = components[child[:tag_name]]

        unless component_class
          warn "No matching component for tag: #{child[:tag_name]}"
          next
        end

        component = component_class.new(
          attributes: child[:attributes] || {},
          children: child[:children] || [],
          content: child[:content] || "",
          context: get_child_context
        )

        component.handler if component.respond_to?(:handler)

        component.render if component.respond_to?(:render)
      end
    end
  end
end
