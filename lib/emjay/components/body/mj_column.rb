# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../registry"
require_relative "../../helpers/width_parser"

module Emjay
  module Components
    class MjColumn < BodyComponent
      def self.component_name
        "mj-column"
      end

      def self.default_attributes
        {
          "direction" => "ltr",
          "vertical-align" => "top"
        }
      end

      def self.allowed_attributes
        {
          "background-color" => "color",
          "border" => "string",
          "border-bottom" => "string",
          "border-left" => "string",
          "border-radius" => "string",
          "border-right" => "string",
          "border-top" => "string",
          "direction" => "enum(ltr,rtl)",
          "inner-background-color" => "color",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "inner-border" => "string",
          "inner-border-bottom" => "string",
          "inner-border-left" => "string",
          "inner-border-radius" => "string",
          "inner-border-right" => "string",
          "inner-border-top" => "string",
          "padding" => "unit(px,%){1,4}",
          "vertical-align" => "enum(top,bottom,middle)",
          "width" => "unit(px,%)"
        }
      end

      def get_child_context
        parent_width = @context[:container_width]
        non_raw_siblings = @props[:non_raw_siblings] || 1
        borders = get_shorthand_border_value("right") + get_shorthand_border_value("left")
        paddings = get_shorthand_attr_value("padding", "right") + get_shorthand_attr_value("padding", "left")
        inner_borders = get_shorthand_border_value("left", "inner-border") +
          get_shorthand_border_value("right", "inner-border")

        all_paddings = paddings + borders + inner_borders

        container_width = get_attribute("width") || "#{parent_width.to_f / non_raw_siblings}px"

        parsed = WidthParser.call(container_width, parse_float_to_int: false)

        container_width = if parsed[:unit] == "%"
          "#{(parent_width.to_f * parsed[:parsed_width]) / 100 - all_paddings}px"
        else
          "#{parsed[:parsed_width] - all_paddings}px"
        end

        @context.merge(container_width: container_width)
      end

      def get_styles
        has_br = has_border_radius?
        has_ibr = has_inner_border_radius?

        table_style = {
          "background-color" => get_attribute("background-color"),
          "border" => get_attribute("border"),
          "border-bottom" => get_attribute("border-bottom"),
          "border-left" => get_attribute("border-left"),
          "border-radius" => get_attribute("border-radius"),
          "border-right" => get_attribute("border-right"),
          "border-top" => get_attribute("border-top"),
          "vertical-align" => get_attribute("vertical-align"),
          **(has_br ? {"border-collapse" => "separate"} : {})
        }

        {
          div: {
            "font-size" => "0px",
            "text-align" => "left",
            "direction" => get_attribute("direction"),
            "display" => "inline-block",
            "vertical-align" => get_attribute("vertical-align"),
            "width" => get_mobile_width
          },
          table: {
            **(has_gutter? ? {
              "background-color" => get_attribute("inner-background-color"),
              "border" => get_attribute("inner-border"),
              "border-bottom" => get_attribute("inner-border-bottom"),
              "border-left" => get_attribute("inner-border-left"),
              "border-radius" => get_attribute("inner-border-radius"),
              "border-right" => get_attribute("inner-border-right"),
              "border-top" => get_attribute("inner-border-top")
            } : table_style),
            **(has_ibr ? {"border-collapse" => "separate"} : {})
          },
          tdOutlook: {
            "vertical-align" => get_attribute("vertical-align"),
            "width" => get_width_as_pixel
          },
          gutter: {
            **table_style,
            "padding" => get_attribute("padding"),
            "padding-top" => get_attribute("padding-top"),
            "padding-right" => get_attribute("padding-right"),
            "padding-bottom" => get_attribute("padding-bottom"),
            "padding-left" => get_attribute("padding-left")
          }
        }
      end

      def render
        classes_name = "#{get_column_class} mj-outlook-group-fix"
        css_class = get_attribute("css-class")
        classes_name += " #{css_class}" if css_class

        <<~HTML
          <div#{html_attributes(class: classes_name, style: :div)}>
            #{has_gutter? ? render_gutter : render_column}
          </div>
        HTML
      end

      private

      def get_mobile_width
        container_width = @context[:container_width]
        non_raw_siblings = @props[:non_raw_siblings] || 1
        width = get_attribute("width")
        mobile_width = get_attribute("mobileWidth")

        return "100%" if mobile_width != "mobileWidth"

        return "#{(100 / non_raw_siblings).to_i}%" unless width

        parsed = WidthParser.call(width, parse_float_to_int: false)

        case parsed[:unit]
        when "%" then width
        else
          "#{(parsed[:parsed_width] / container_width.to_f) * 100}%"
        end
      end

      def get_width_as_pixel
        container_width = @context[:container_width]
        parsed = WidthParser.call(get_parsed_width(true), parse_float_to_int: false)

        if parsed[:unit] == "%"
          "#{format_float((container_width.to_f * parsed[:parsed_width]) / 100)}px"
        else
          "#{format_float(parsed[:parsed_width])}px"
        end
      end

      def get_parsed_width(to_string = false)
        non_raw_siblings = @props[:non_raw_siblings] || 1
        width = get_attribute("width") || "#{100.0 / non_raw_siblings}%"

        parsed = WidthParser.call(width, parse_float_to_int: false)

        if to_string
          "#{format_float(parsed[:parsed_width])}#{parsed[:unit]}"
        else
          parsed
        end
      end

      def get_column_class
        add_media_query = @context[:add_media_query]

        parsed = get_parsed_width
        formatted = format_float(parsed[:parsed_width]).to_s.tr(".", "-")

        class_name = case parsed[:unit]
        when "%" then "mj-column-per-#{formatted}"
        else "mj-column-px-#{formatted}"
        end

        add_media_query&.call(class_name, parsed)

        class_name
      end

      # Formats a float to match JS toString() — strips trailing .0
      def format_float(value)
        (value == value.to_i) ? value.to_i : value
      end

      def has_border_radius?
        br = get_attribute("border-radius")
        br && !br.empty?
      end

      def has_inner_border_radius?
        ibr = get_attribute("inner-border-radius")
        ibr && !ibr.empty?
      end

      def has_gutter?
        %w[padding padding-bottom padding-left padding-right padding-top].any? { |attr|
          !get_attribute(attr).nil?
        }
      end

      def render_gutter
        has_br = has_border_radius?

        <<~HTML
          <table#{html_attributes(
            border: "0",
            cellpadding: "0",
            cellspacing: "0",
            role: "presentation",
            width: "100%",
            **(has_br ? {style: {"border-collapse" => "separate"}} : {})
          )}>
            <tbody>
              <tr>
                <td#{html_attributes(style: :gutter)}>
                  #{render_column}
                </td>
              </tr>
            </tbody>
          </table>
        HTML
      end

      def render_column
        children = @props[:children] || []

        <<~HTML
          <table#{html_attributes(
            border: "0",
            cellpadding: "0",
            cellspacing: "0",
            role: "presentation",
            style: :table,
            width: "100%"
          )}>
            <tbody>
              #{render_children(children, renderer: ->(component) {
                if component.class.raw_element?
                  component.render
                else
                  <<~CELL
                    <tr>
                      <td#{component.html_attributes(
                        align: component.get_attribute("align"),
                        class: component.get_attribute("css-class"),
                        style: {
                          "background" => component.get_attribute("container-background-color"),
                          "font-size" => "0px",
                          "padding" => component.get_attribute("padding"),
                          "padding-top" => component.get_attribute("padding-top"),
                          "padding-right" => component.get_attribute("padding-right"),
                          "padding-bottom" => component.get_attribute("padding-bottom"),
                          "padding-left" => component.get_attribute("padding-left"),
                          "word-break" => "break-word"
                        }
                      )}>
                        #{component.render}
                      </td>
                    </tr>
                  CELL
                end
              })}
            </tbody>
          </table>
        HTML
      end
    end
  end

  Registry.register(Components::MjColumn)
end
