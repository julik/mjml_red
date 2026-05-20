# frozen_string_literal: true

module Emjay
  module SuffixCssClasses
    # Appends a suffix to each CSS class in a space-separated string.
    # Port of suffixCssClasses.js
    def self.call(classes, suffix)
      return "" unless classes && !classes.empty?
      classes.split(" ").map { |c| "#{c}-#{suffix}" }.join(" ")
    end
  end
end
