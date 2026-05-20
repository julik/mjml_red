# frozen_string_literal: true

require_relative "mj_section"

module MjmlRed
  module Components
    class MjWrapper < MjSection
      def self.component_name
        "mj-wrapper"
      end

      def self.allowed_attributes
        MjSection.allowed_attributes.merge("gap" => "unit(px)")
      end

      def get_child_context
        widths = get_box_widths
        @context.merge(
          container_width: "#{widths[:box]}px",
          gap: get_attribute("gap")
        )
      end

      private

      def render_wrapped_children
        children = @props[:children] || []
        container_width = @context[:container_width]

        rendered = render_children(children, renderer: ->(component) {
          if component.class.raw_element?
            component.render
          else
            <<~HTML
              <!--[if mso | IE]>
                <tr>
                  <td#{component.html_attributes(
                    align: component.get_attribute("align"),
                    class: SuffixCssClasses.call(component.get_attribute("css-class"), "outlook"),
                    width: container_width
                  )}>
              <![endif]-->
                #{component.render}
              <!--[if mso | IE]>
                  </td>
                </tr>
              <![endif]-->
            HTML
          end
        })

        rendered
      end
    end
  end

  Registry.register(Components::MjWrapper)
end
