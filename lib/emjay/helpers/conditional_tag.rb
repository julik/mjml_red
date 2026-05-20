# frozen_string_literal: true

module Emjay
  module ConditionalTag
    START_CONDITIONAL_TAG = "<!--[if mso | IE]>"
    START_MSO_CONDITIONAL_TAG = "<!--[if mso]>"
    END_CONDITIONAL_TAG = "<![endif]-->"
    START_NEGATION_CONDITIONAL_TAG = "<!--[if !mso | IE]><!-->"
    START_MSO_NEGATION_CONDITIONAL_TAG = "<!--[if !mso]><!-->"
    END_NEGATION_CONDITIONAL_TAG = "<!--<![endif]-->"

    def self.conditional_tag(content, negation: false)
      start_tag = negation ? START_NEGATION_CONDITIONAL_TAG : START_CONDITIONAL_TAG
      end_tag = negation ? END_NEGATION_CONDITIONAL_TAG : END_CONDITIONAL_TAG
      "\n    #{start_tag}\n    #{content}\n    #{end_tag}\n  "
    end

    def self.mso_conditional_tag(content, negation: false)
      start_tag = negation ? START_MSO_NEGATION_CONDITIONAL_TAG : START_MSO_CONDITIONAL_TAG
      end_tag = negation ? END_NEGATION_CONDITIONAL_TAG : END_CONDITIONAL_TAG
      "\n    #{start_tag}\n    #{content}\n    #{end_tag}\n  "
    end
  end
end
