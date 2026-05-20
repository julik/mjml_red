# frozen_string_literal: true

module Emjay
  class GlobalData
    ARRAY_FIELDS = %i[inline_style components_head_style head_raw style].freeze
    HASH_FIELDS = %i[classes classes_default default_attributes html_attributes fonts head_style media_queries].freeze
    SCALAR_FIELDS = %i[before_doctype breakpoint preview title force_owa_desktop lang dir].freeze

    attr_accessor(*ARRAY_FIELDS, *HASH_FIELDS, *SCALAR_FIELDS)

    def initialize(options = {})
      @before_doctype = ""
      @breakpoint = options[:breakpoint] || "480px"
      @classes = {}
      @classes_default = {}
      @default_attributes = {}
      @html_attributes = {}
      @fonts = options.fetch(:fonts, default_fonts)
      @inline_style = []
      @head_style = {}
      @components_head_style = []
      @head_raw = []
      @media_queries = {}
      @preview = ""
      @style = []
      @title = ""
      @force_owa_desktop = false
      @lang = "und"
      @dir = "auto"
    end

    # Mirrors JS headHelpers.add() semantics
    def add(key, *params)
      val = send(key)
      if val.is_a?(Array)
        val.push(*params)
      elsif val.is_a?(Hash)
        if params.length > 1
          val[params[0]] = if val[params[0]].is_a?(Hash)
            val[params[0]].merge(params[1])
          else
            params[1]
          end
        else
          send(:"#{key}=", params[0])
        end
      else
        send(:"#{key}=", params[0])
      end
    end

    private

    def default_fonts
      {
        "Open Sans" => "https://fonts.googleapis.com/css?family=Open+Sans:300,400,500,700",
        "Droid Sans" => "https://fonts.googleapis.com/css?family=Droid+Sans:300,400,500,700",
        "Lato" => "https://fonts.googleapis.com/css?family=Lato:300,400,500,700",
        "Roboto" => "https://fonts.googleapis.com/css?family=Roboto:300,400,500,700",
        "Ubuntu" => "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700"
      }
    end
  end
end
