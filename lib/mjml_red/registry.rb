# frozen_string_literal: true

module MjmlRed
  module Registry
    @components = {}

    def self.register(component_class)
      @components[component_class.component_name] = component_class
    end

    def self.find(tag_name)
      @components[tag_name]
    end

    def self.components
      @components
    end
  end
end
