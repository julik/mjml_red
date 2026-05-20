# frozen_string_literal: true

require_relative "component"
require_relative "helpers/shorthand_parser"
require_relative "helpers/width_parser"

module MjmlRed
  # Base class for body components. Port of JS BodyComponent from createComponent.js.
  class BodyComponent < Component
    def get_styles
      {}
    end

    # Converts a style hash (or style name string) to an inline CSS string.
    # Supports dot-notation for nested style lookups (e.g., "carousel.div").
    def styles(name_or_hash)
      styles_object = if name_or_hash.is_a?(String)
        if name_or_hash.include?(".")
          parts = name_or_hash.split(".")
          result = get_styles
          parts.each { |part| result = result&.dig(part.to_sym) || result&.dig(part) }
          result
        else
          get_styles[name_or_hash.to_sym] || get_styles[name_or_hash]
        end
      elsif name_or_hash.is_a?(Symbol)
        get_styles[name_or_hash]
      else
        name_or_hash
      end

      return "" unless styles_object

      styles_object.each_with_object(+"") do |(name, value), output|
        output << "#{name}:#{value};" unless value.nil?
      end
    end

    # Builds an HTML attribute string. The `style:` key auto-resolves through #styles.
    def html_attributes(attrs)
      attrs.each_with_object(+"") do |(name, value), output|
        next if value.nil?
        resolved = if name.to_s == "style"
          styles(value)
        else
          value
        end
        output << " #{name}=\"#{resolved}\""
      end
    end

    def get_shorthand_attr_value(attribute, direction)
      dir_attr = get_attribute("#{attribute}-#{direction}")
      return dir_attr.to_i if dir_attr

      base_attr = get_attribute(attribute)
      return 0 unless base_attr

      ShorthandParser.call(base_attr, direction)
    end

    def get_shorthand_border_value(direction, attribute = "border")
      border_direction = direction && get_attribute("#{attribute}-#{direction}")
      border = get_attribute(attribute)
      BorderParser.call(border_direction || border || "0")
    end

    def get_box_widths
      container_width = @context[:container_width]
      parsed_width = container_width.to_i

      paddings = get_shorthand_attr_value("padding", "right") +
        get_shorthand_attr_value("padding", "left")

      borders = get_shorthand_border_value("right") +
        get_shorthand_border_value("left")

      {
        total_width: parsed_width,
        borders: borders,
        paddings: paddings,
        box: parsed_width - paddings - borders
      }
    end

    def get_child_context
      @context
    end

    # Renders child components. Supports renderer: lambda, attributes: merge, raw_xml: mode.
    def render_children(children = nil, opts = {})
      renderer = opts[:renderer] || ->(component) { component.render }
      extra_attributes = opts[:attributes] || {}
      extra_props = opts[:props] || {}

      children = children || @props[:children] || []

      sibling = children.length
      components = @context[:components] || {}

      raw_components = components.values.select { |c| c.raw_element? }
      non_raw_siblings = children.count { |child|
        !raw_components.any? { |c| c.component_name == child[:tag_name] }
      }

      output = +""
      children.each_with_index do |child, index|
        component_class = components[child[:tag_name]]
        next unless component_class

        child_data = {
          attributes: extra_attributes.merge(child[:attributes] || {}),
          children: child[:children] || [],
          content: child[:content] || "",
          context: get_child_context,
          global_attributes: child[:global_attributes] || {},
          raw_attrs: child[:raw_attrs] || {},
          props: extra_props.merge(
            first: index == 0,
            index: index,
            last: index + 1 == sibling,
            sibling: sibling,
            non_raw_siblings: non_raw_siblings
          )
        }

        component = component_class.new(child_data)

        if component.respond_to?(:head_style)
          @context[:add_head_style]&.call(child[:tag_name], component.method(:head_style))
        end
        if component.respond_to?(:component_head_style)
          @context[:add_component_head_style]&.call(component.method(:component_head_style))
        end

        output << renderer.call(component)
      end

      output
    end
  end
end
