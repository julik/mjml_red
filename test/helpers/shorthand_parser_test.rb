# frozen_string_literal: true

require_relative "../test_helper"

class ShorthandParserTest < Minitest::Test
  DIRECTIONS = %w[top right bottom left].freeze

  TEST_VALUES = [
    {input: "1px", output: {top: 1, right: 1, bottom: 1, left: 1}},
    {input: "1px 0", output: {top: 1, right: 0, bottom: 1, left: 0}},
    {input: "1px 2px 3px", output: {top: 1, right: 2, bottom: 3, left: 2}},
    {input: "1px 2px 3px 4px", output: {top: 1, right: 2, bottom: 3, left: 4}},
    {input: " 1px 2px  3px 4px ", output: {top: 1, right: 2, bottom: 3, left: 4}}
  ].freeze

  TEST_VALUES.each_with_index do |test_case, idx|
    DIRECTIONS.each do |dir|
      define_method("test_case_#{idx + 1}_#{dir}") do
        result = Emjay::ShorthandParser.call(test_case[:input], dir)
        assert_equal test_case[:output][dir.to_sym], result,
          "Case #{idx + 1}: shorthandParser(#{test_case[:input].inspect}, #{dir}) failed"
      end
    end
  end
end

class BorderParserTest < Minitest::Test
  def test_parses_border_width
    assert_equal 1, Emjay::BorderParser.call("1px solid black")
  end

  def test_returns_zero_for_no_match
    assert_equal 0, Emjay::BorderParser.call("none")
  end

  def test_returns_zero_for_empty
    assert_equal 0, Emjay::BorderParser.call("0")
  end
end
