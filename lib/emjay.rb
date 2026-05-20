# frozen_string_literal: true

require_relative "emjay/version"
require_relative "emjay/registry"
require_relative "emjay/component"
require_relative "emjay/body_component"
require_relative "emjay/head_component"
require_relative "emjay/global_data"
require_relative "emjay/renderer"
require_relative "emjay/skeleton"

# Helpers
require_relative "emjay/helpers/shorthand_parser"
require_relative "emjay/helpers/width_parser"
require_relative "emjay/helpers/conditional_tag"
require_relative "emjay/helpers/suffix_css_classes"
require_relative "emjay/helpers/merge_outlook_conditionals"
require_relative "emjay/helpers/minify_outlook_conditionals"
require_relative "emjay/helpers/fonts"
require_relative "emjay/helpers/media_queries"
require_relative "emjay/helpers/styles"
require_relative "emjay/helpers/make_lower_breakpoint"
require_relative "emjay/helpers/gen_random_hex_string"

# Head components
require_relative "emjay/components/head/mj_head"
require_relative "emjay/components/head/mj_attributes"
require_relative "emjay/components/head/mj_style"
require_relative "emjay/components/head/mj_font"
require_relative "emjay/components/head/mj_title"
require_relative "emjay/components/head/mj_preview"
require_relative "emjay/components/head/mj_breakpoint"
require_relative "emjay/components/head/mj_html_attributes"

# Body components
require_relative "emjay/components/body/mj_body"
require_relative "emjay/components/body/mj_section"
require_relative "emjay/components/body/mj_column"
require_relative "emjay/components/body/mj_text"
require_relative "emjay/components/body/mj_wrapper"
require_relative "emjay/components/body/mj_group"
require_relative "emjay/components/body/mj_image"
require_relative "emjay/components/body/mj_button"
require_relative "emjay/components/body/mj_divider"
require_relative "emjay/components/body/mj_spacer"
require_relative "emjay/components/body/mj_table"
require_relative "emjay/components/body/mj_raw"
require_relative "emjay/components/body/mj_hero"
require_relative "emjay/components/body/mj_social"
require_relative "emjay/components/body/mj_social_element"
require_relative "emjay/components/body/mj_navbar"
require_relative "emjay/components/body/mj_navbar_link"
require_relative "emjay/components/body/mj_accordion"
require_relative "emjay/components/body/mj_accordion_element"
require_relative "emjay/components/body/mj_accordion_title"
require_relative "emjay/components/body/mj_accordion_text"
require_relative "emjay/components/body/mj_carousel"
require_relative "emjay/components/body/mj_carousel_image"

module Emjay
  def self.to_html(mjml_string, options = {})
    Renderer.call(mjml_string, options)
  end
end

require "emjay/railtie" if defined?(Rails::Railtie)
