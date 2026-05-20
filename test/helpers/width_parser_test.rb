# frozen_string_literal: true

require_relative "../test_helper"

class WidthParserTest < Minitest::Test
  def test_parses_1px
    result = MjmlRed::WidthParser.call("1px")
    assert_equal({parsed_width: 1, unit: "px"}, result)
  end

  def test_parses_33_3px_truncates_to_int
    result = MjmlRed::WidthParser.call("33.3px")
    assert_equal({parsed_width: 33, unit: "px"}, result)
  end

  def test_parses_33_3_percent_truncates_to_int
    result = MjmlRed::WidthParser.call("33.3%")
    assert_equal({parsed_width: 33, unit: "%"}, result)
  end

  def test_parses_33_3_percent_as_float
    result = MjmlRed::WidthParser.call("33.3%", parse_float_to_int: false)
    assert_equal({parsed_width: 33.3, unit: "%"}, result)
  end
end
