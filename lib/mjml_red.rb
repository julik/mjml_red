# frozen_string_literal: true

require_relative "mjml_red/version"
require_relative "mjml_red/registry"
require_relative "mjml_red/component"
require_relative "mjml_red/body_component"
require_relative "mjml_red/head_component"
require_relative "mjml_red/global_data"
require_relative "mjml_red/renderer"
require_relative "mjml_red/skeleton"

# Helpers
require_relative "mjml_red/helpers/shorthand_parser"
require_relative "mjml_red/helpers/width_parser"
require_relative "mjml_red/helpers/conditional_tag"
require_relative "mjml_red/helpers/suffix_css_classes"
require_relative "mjml_red/helpers/merge_outlook_conditionals"
require_relative "mjml_red/helpers/minify_outlook_conditionals"
require_relative "mjml_red/helpers/fonts"
require_relative "mjml_red/helpers/media_queries"
require_relative "mjml_red/helpers/styles"

# Head components
require_relative "mjml_red/components/head/mj_head"
require_relative "mjml_red/components/head/mj_attributes"
require_relative "mjml_red/components/head/mj_style"
require_relative "mjml_red/components/head/mj_font"
require_relative "mjml_red/components/head/mj_title"
require_relative "mjml_red/components/head/mj_preview"
require_relative "mjml_red/components/head/mj_breakpoint"
require_relative "mjml_red/components/head/mj_html_attributes"

# Body components
require_relative "mjml_red/components/body/mj_body"
require_relative "mjml_red/components/body/mj_section"
require_relative "mjml_red/components/body/mj_column"
require_relative "mjml_red/components/body/mj_text"

module MjmlRed
  def self.to_html(mjml_string, options = {})
    Renderer.call(mjml_string, options)
  end
end
