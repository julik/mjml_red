# frozen_string_literal: true

module MjmlRed
  module Styles
    # Builds <style> tag from component head styles and head style functions.
    # Port of styles.js buildStyleFromComponents
    def self.build_from_components(breakpoint, components_head_style, head_style)
      head_styles = head_style.values
      all = components_head_style + head_styles

      return "" if all.empty?

      css = all.map { |style_fn| style_fn.call(breakpoint) }.join("\n")

      <<~HTML.chomp
        <style type="text/css">#{css}
        </style>
      HTML
    end

    # Builds <style> tag from user-provided style strings/procs.
    # Port of styles.js buildStyleFromTags
    def self.build_from_tags(breakpoint, styles)
      return "" if styles.empty?

      css = styles.map { |style| style.respond_to?(:call) ? style.call(breakpoint) : style }.join("\n")

      <<~HTML.chomp
        <style type="text/css">#{css}
        </style>
      HTML
    end
  end
end
