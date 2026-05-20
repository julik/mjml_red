# frozen_string_literal: true

module MjmlRed
  module MediaQueries
    # Builds <style> tags for responsive media queries.
    # Port of mediaQueries.js
    def self.build_tags(breakpoint, media_queries = {}, force_owa_desktop: false, printer_support: false)
      return "" if media_queries.empty?

      base = media_queries.map { |class_name, mq| ".#{class_name} #{mq}" }
      thunderbird = media_queries.map { |class_name, mq| ".moz-text-html .#{class_name} #{mq}" }
      owa = base.map { |mq| "[owa] #{mq}" }

      result = +""
      result << <<~HTML
        <style type="text/css">
          @media only screen and (min-width:#{breakpoint}) {
            #{base.join("\n")}
          }
        </style>
        <style media="screen and (min-width:#{breakpoint})">
          #{thunderbird.join("\n")}
        </style>
      HTML

      if printer_support
        result << <<~HTML
          <style type="text/css">
            @media only print {
              #{base.join("\n")}
            }
          </style>
        HTML
      end

      if force_owa_desktop
        result << <<~HTML
          <style type="text/css">
            #{owa.join("\n")}
          </style>
        HTML
      end

      result
    end
  end
end
