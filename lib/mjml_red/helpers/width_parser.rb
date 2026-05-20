# frozen_string_literal: true

module MjmlRed
  module WidthParser
    UNIT_REGEX = /[\d.,]*(\D*)$/

    # Parses a width string like "600px" or "50%" into { parsed_width:, unit: }.
    # Port of widthParser.js
    def self.call(width, parse_float_to_int: true)
      width_str = width.to_s
      unit_match = UNIT_REGEX.match(width_str)
      width_unit = unit_match ? unit_match[1] : ""

      parsed_width = if width_unit == "%" && !parse_float_to_int
        width_str.to_f
      else
        width_str.to_i
      end

      {
        parsed_width: parsed_width,
        unit: width_unit.empty? ? "px" : width_unit
      }
    end
  end
end
