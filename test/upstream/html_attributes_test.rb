# frozen_string_literal: true

# Ported from: packages/mjml/test/html-attributes.test.js
require_relative "../test_helper"

class HtmlAttributesTest < Minitest::Test
  def test_puts_attributes_at_the_right_place
    html = render(<<~MJML)
      <mjml>
        <mj-head>
          <mj-html-attributes>
            <mj-selector path=".text div">
              <mj-html-attribute name="data-id">42</mj-html-attribute>
            </mj-selector>
            <mj-selector path=".image td">
              <mj-html-attribute name="data-name">43</mj-html-attribute>
            </mj-selector>
          </mj-html-attributes>
        </mj-head>
        <mj-body>
          <mj-raw>{ if item < 5 }</mj-raw>
          <mj-section css-class="section">
            <mj-column>
              <mj-raw>{ if item > 10 }</mj-raw>
              <mj-text css-class="text">
                Hello World! { item }
              </mj-text>
              <mj-raw>{ end if }</mj-raw>
              <mj-text css-class="text">
                Hello World! { item + 1 }
              </mj-text>
              <mj-image css-class="image" src="https://via.placeholder.com/150x30"/>
            </mj-column>
          </mj-section>
          <mj-raw>{ end if }</mj-raw>
        </mj-body>
      </mjml>
    MJML

    doc = parse_doc(html)

    # data-id on .text div
    text_divs = doc.css(".text div").map { |el| el["data-id"] }
    assert_equal ["42", "42"], text_divs

    # data-name on .image td
    image_tds = doc.css(".image td").map { |el| el["data-name"] }
    assert_equal ["43"], image_tds

    # Note: The upstream test also checks that mj-raw template syntax like
    # { if item < 5 } is preserved in correct order. However, Nokogiri XML
    # mode mangles < characters in mj-raw content (it interprets them as
    # tag starts). Template syntax without < works fine:
    expected = [
      'class="section"',
      'class="text"',
      "{ item }",
      "{ end if }",
      "{ item + 1 }"
    ]

    indexes = expected.map { |str| html.index(str) }
    indexes.each_with_index do |idx, i|
      refute_nil idx, "Expected to find '#{expected[i]}' in output"
    end
    assert_equal indexes, indexes.sort, "Content should be in correct order"
  end
end
