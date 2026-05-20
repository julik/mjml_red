# frozen_string_literal: true

module Emjay
  module Fonts
    # Builds font import tags (<link> and @import) for fonts used in the content.
    # Port of fonts.js buildFontsTags
    def self.build_tags(content, inline_style, fonts = {})
      to_import = []

      fonts.each do |name, url|
        regex = /"[^"]*font-family:[^"]*#{Regexp.escape(name)}[^"]*"/mi
        inline_regex = /font-family:[^;}]*#{Regexp.escape(name)}/mi

        if content.match?(regex) || inline_style.any? { |s| s.match?(inline_regex) }
          to_import << url
        end
      end

      return "" if to_import.empty?

      links = to_import.map { |url| %(<link href="#{url}" rel="stylesheet" type="text/css">) }.join("\n")
      imports = to_import.map { |url| "@import url(#{url});" }.join("\n")

      <<~HTML
        <!--[if !mso]><!-->
          #{links}
          <style type="text/css">
            #{imports}
          </style>
        <!--<![endif]-->
      HTML
    end
  end
end
