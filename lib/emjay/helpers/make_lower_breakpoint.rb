# frozen_string_literal: true

module Emjay
  module MakeLowerBreakpoint
    # Given a breakpoint string like "600px", returns "599px".
    # Port of mjml-core/src/helpers/makeLowerBreakpoint.js
    def self.call(breakpoint)
      match = breakpoint.to_s.match(/[0-9]+/)
      return breakpoint unless match

      pixels = match[0].to_i
      "#{pixels - 1}px"
    rescue
      breakpoint
    end
  end
end
