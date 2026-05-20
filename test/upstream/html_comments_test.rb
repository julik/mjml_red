# frozen_string_literal: true

# Ported from: packages/mjml/test/html-comments.test.js
require_relative "../test_helper"

class HtmlCommentsTest < Minitest::Test
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

    assert_includes html, "<!-- comment with standard spaces -->",
      "Standard-spaced comment should be preserved"
    assert_includes html, "<!--comment without spaces-->",
      "Comment without spaces should be preserved"
    assert_includes html, "<!--     comment with 5 spaces     -->",
      "Comment with 5 spaces should be preserved"
  end
end
