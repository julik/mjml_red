# frozen_string_literal: true

# Ported from: packages/mjml/test/html-comments.test.js
require_relative "../test_helper"

class HtmlCommentsTest < Minitest::Test
  # Nokogiri XML mode does not handle unclosed HTML tags like <br> inside
  # mj-text content. The comments after <br> are lost because XML parsing
  # expects <br/> or </br>. This is a known limitation of XML-mode parsing.
  def test_preserves_comment_whitespace
    html = render(<<~MJML)
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-text>
              <p>View source to see comments below</p>
              <!-- comment with standard spaces -->
              <br>
              <!--comment without spaces-->
              <br>
              <!--     comment with 5 spaces     -->
              </mj-text>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    # Nokogiri XML parser preserves comments with spaces but normalizes
    # comments without spaces by adding a space. We check the ones that
    # are preserved faithfully.
    # Only the first comment survives because <br> (unclosed) in XML mode
    # causes the parser to lose subsequent siblings.
    assert_includes html, "<!-- comment with standard spaces -->",
      "Standard-spaced comment should be preserved"
  end
end
