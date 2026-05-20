# frozen_string_literal: true

module Emjay
  module ShorthandParser
    # Parses CSS shorthand values (like padding/margin) into per-direction integers.
    # Port of shorthandParser.js
    def self.call(css_value, direction)
      parts = css_value.to_s.strip.gsub(/\s+/, " ").split(" ", 4)

      directions = case parts.length
      when 2
        {top: 0, bottom: 0, left: 1, right: 1}
      when 3
        {top: 0, left: 1, right: 1, bottom: 2}
      when 4
        {top: 0, right: 1, bottom: 2, left: 3}
      else
        return css_value.to_i
      end

      (parts[directions[direction.to_sym]] || "0").to_i
    end
  end

  module BorderParser
    # Extracts the first number from a border string (e.g. "1px solid black" -> 1).
    # Port of borderParser in shorthandParser.js
    def self.call(border)
      match = border.to_s.match(/(?:(?:^| )(\d+))/)
      match ? match[1].to_i : 0
    end
  end
end
