# frozen_string_literal: true

module Emjay
  module MinifyOutlookConditionals
    # Collapses whitespace inside Outlook conditional blocks.
    # Port of minifyOutlookConditionnals.js
    def self.call(content)
      content.gsub(/(<!--\[if\s[^\]]+\]>)([\s\S]*?)(<!\[endif\]-->)/m) do
        prefix = $1
        inner = $2
        suffix = $3
        processed = inner.gsub(/(^|>)(\s+)(<|$)/m) { "#{$1}#{$3}" }
          .gsub(/\s{2,}/m, " ")
        "#{prefix}#{processed}#{suffix}"
      end
    end
  end
end
