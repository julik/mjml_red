# frozen_string_literal: true

require_relative "../../head_component"
require_relative "../../registry"

module Emjay
  module Components
    class MjHtmlAttributes < HeadComponent
      def self.component_name
        "mj-html-attributes"
      end

      def handler
        add = @context[:add]
        children = @props[:children] || []

        children.select { |c| c[:tag_name] == "mj-selector" }.each do |selector|
          path = (selector[:attributes] || {})["path"]

          custom = (selector[:children] || [])
            .select { |c| c[:tag_name] == "mj-html-attribute" && (c[:attributes] || {})["name"] }
            .each_with_object({}) { |c, acc|
              acc[c[:attributes]["name"]] = c[:content] || ""
            }

          add.call(:html_attributes, path, custom)
        end
      end
    end
  end

  Registry.register(Components::MjHtmlAttributes)
end
