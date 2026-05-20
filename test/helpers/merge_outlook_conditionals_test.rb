# frozen_string_literal: true

require_relative "../test_helper"

class MergeOutlookConditionalsTest < Minitest::Test
  def test_removes_simple_pair
    input = "<![endif]--><!--[if mso | IE]>"
    assert_equal "", MjmlRed::MergeOutlookConditionals.call(input)
  end

  def test_removes_with_surrounding_content
    input = "\n    </tr>\n    <![endif]-->\n    <!--[if mso | IE]>\n    </td>"
    expected = "\n    </tr>\n    \n    </td>"
    assert_equal expected, MjmlRed::MergeOutlookConditionals.call(input)
  end

  def test_merges_multiple_pairs
    input = "</div>\n              <!--[if mso | IE]>\n            </td>\n          <![endif]-->\n              <!--[if mso | IE]>\n        </tr>\n      <![endif]-->\n              <!--[if mso | IE]>\n                  </table>\n                <![endif]-->\n            </td>\n          </tr>\n        </tbody>\n      </table>\n    </div>\n    <!--[if mso | IE]>\n          </td>"
    expected = "</div>\n              <!--[if mso | IE]>\n            </td>\n          \n        </tr>\n      \n                  </table>\n                <![endif]-->\n            </td>\n          </tr>\n        </tbody>\n      </table>\n    </div>\n    <!--[if mso | IE]>\n          </td>"
    assert_equal expected, MjmlRed::MergeOutlookConditionals.call(input)
  end
end
