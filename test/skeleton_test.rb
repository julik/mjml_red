# frozen_string_literal: true

require_relative "test_helper"

class SkeletonTest < Minitest::Test
  # The conditional style tag for Outlook does not get parsed by Nokogiri/CSS,
  # so each expected count excludes it
  TEST_CASES = [
    {options: {}, expected_style_count: 1},
    {
      options: {
        components_head_style: [
          ->(_bp) { ".custom-component-1 .custom-child { background: red; }" }
        ]
      },
      expected_style_count: 2
    },
    {
      options: {
        head_style: {
          "custom-component" => ->(_bp) { ".custom-component .custom-child { background: orange; }" }
        }
      },
      expected_style_count: 2
    },
    {
      options: {
        components_head_style: [
          ->(_bp) { ".custom-component-1 .custom-child { background: yellow; }" }
        ],
        head_style: {
          "custom-component" => ->(_bp) { ".custom-component .custom-child { background: green; }" }
        }
      },
      expected_style_count: 2
    },
    {
      options: {
        style: ["#title { background: blue; }"]
      },
      expected_style_count: 2
    },
    {
      options: {
        components_head_style: [
          ->(_bp) { ".custom-component-1 .custom-child { background: purple; }" }
        ],
        head_style: {
          "custom-component" => ->(_bp) { ".custom-component .custom-child { background: black; }" }
        },
        style: [->(_bp) { "#title { background: white; }" }]
      },
      expected_style_count: 3
    }
  ].freeze

  TEST_CASES.each_with_index do |test_case, idx|
    define_method("test_style_tag_count_case_#{idx + 1}") do
      html = Emjay::Skeleton.call(test_case[:options])
      doc = Nokogiri::HTML(html)
      # Count style tags in head (Nokogiri can parse regular ones but not
      # those inside conditional comments, so we count the same way as upstream)
      style_count = doc.css("head style").length
      assert_equal test_case[:expected_style_count], style_count,
        "Case #{idx + 1}: unexpected number of style tags"
    end
  end
end
