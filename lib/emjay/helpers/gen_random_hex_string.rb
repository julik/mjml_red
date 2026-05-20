# frozen_string_literal: true

module Emjay
  module GenRandomHexString
    def self.call(length)
      length.times.map { rand(16).to_s(16) }.join
    end
  end
end
