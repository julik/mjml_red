# frozen_string_literal: true

module Emjay
  # Base class for all MJML components. Port of JS Component class from createComponent.js.
  # Takes parsed node data (attributes, children, content) + context hash.
  class Component
    attr_reader :attributes, :props, :context

    class << self
      def component_name
        raise NotImplementedError, "#{name} must define self.component_name"
      end

      def ending_tag?
        false
      end

      def raw_element?
        false
      end

      def default_attributes
        {}
      end

      def allowed_attributes
        {}
      end
    end

    # initialDatas in JS: { attributes, children, content, context, props, globalAttributes, rawAttrs }
    def initialize(initial_data = {})
      attrs = initial_data[:attributes] || {}
      @children = initial_data[:children] || []
      @content = initial_data[:content] || ""
      @context = initial_data[:context] || {}
      @props = initial_data[:props] || {}
      @props[:children] = @children
      @props[:content] = @content
      @props[:raw_attrs] = initial_data[:raw_attrs] || {}
      global_attributes = initial_data[:global_attributes] || {}

      # Attribute merging: defaults -> global -> element
      @attributes = self.class.default_attributes
        .merge(global_attributes)
        .merge(attrs)
    end

    def get_child_context
      @context
    end

    def get_attribute(name)
      @attributes[name]
    end

    def get_content
      (@content || "").strip
    end
  end
end
