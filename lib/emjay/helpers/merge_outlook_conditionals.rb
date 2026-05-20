# frozen_string_literal: true

module Emjay
  module MergeOutlookConditionals
    # Removes adjacent `<![endif]-->...<!--[if mso | IE]>` pairs.
    # Port of mergeOutlookConditionnals.js
    def self.call(content)
      content.gsub(/<!\[endif\]-->\s*?<!--\[if mso \| IE\]>/m, "")
    end
  end
end
