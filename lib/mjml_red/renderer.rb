# frozen_string_literal: true

require "nokogiri"
require_relative "global_data"
require_relative "registry"
require_relative "skeleton"
require_relative "helpers/merge_outlook_conditionals"
require_relative "helpers/minify_outlook_conditionals"

module MjmlRed
  module Renderer
    def self.call(mjml_string, options = {})
      # 1. Parse MJML string with Nokogiri
      doc = Nokogiri::XML(mjml_string)
      mjml_root = doc.at_xpath("//mjml") || doc.root

      # 2. Build GlobalData
      global_data = GlobalData.new(options)

      # Extract lang/dir from root element
      if mjml_root
        owa = mjml_root["owa"]
        global_data.force_owa_desktop = (owa == "desktop") if owa
        global_data.lang = mjml_root["lang"] || "und"
        global_data.dir = mjml_root["dir"] || "auto"
      end

      # 3. Find mj-head and mj-body
      mj_head_el = mjml_root&.at_xpath("mj-head")
      mj_body_el = mjml_root&.at_xpath("mj-body")

      # Convert Nokogiri elements to our internal data structures (matching JS parsed format)
      components = Registry.components

      # Processing function (matches JS processing)
      apply_attributes = method(:apply_attributes_fn).curry[global_data]

      processing = lambda { |node, ctx|
        return unless node
        node = apply_attributes.call(node) if node.is_a?(Hash)

        component_class = ctx[:components]&.[](node[:tag_name])
        return unless component_class

        component = component_class.new(
          attributes: node[:attributes] || {},
          children: node[:children] || [],
          content: node[:content] || "",
          context: ctx,
          global_attributes: node[:global_attributes] || {},
          raw_attrs: node[:raw_attrs] || {}
        )

        if component.respond_to?(:handler)
          return component.handler
        end

        if component.respond_to?(:render)
          return component.render
        end
      }

      # Head helpers context
      head_helpers = {
        components: components,
        global_data: global_data,
        add: ->(attr, *params) { global_data.add(attr, *params) }
      }

      # Process head
      if mj_head_el
        head_node = nokogiri_to_hash(mj_head_el)
        head_result = processing.call(head_node, head_helpers)
        global_data.head_raw = head_result if head_result.is_a?(Array)
      end

      # Body helpers context
      body_helpers = {
        components: components,
        global_data: global_data,
        container_width: "600px",
        add_media_query: ->(class_name, data) {
          pw = data[:parsed_width]
          pw = pw.to_i if pw == pw.to_i
          global_data.media_queries[class_name] =
            "{ width:#{pw}#{data[:unit]} !important; max-width: #{pw}#{data[:unit]}; }"
        },
        add_head_style: ->(identifier, head_style_fn) {
          global_data.head_style[identifier] = head_style_fn
        },
        add_component_head_style: ->(head_style_fn) {
          global_data.components_head_style << head_style_fn
        },
        processing: ->(node, ctx) {
          node = apply_attributes.call(node) if node.is_a?(Hash)
          processing.call(node, ctx)
        }
      }

      # Process body
      content = nil
      if mj_body_el
        body_node = nokogiri_to_hash(mj_body_el)
        body_node = apply_attributes.call(body_node)
        content = processing.call(body_node, body_helpers)
      end

      raise "Malformed MJML. Check that your structure is correct and enclosed in <mjml> tags." unless content

      # Minify outlook conditionals
      content = MinifyOutlookConditionals.call(content)

      # Handle mj-raw outside body (before-doctype)
      mjml_root&.xpath("mj-raw").each do |raw_el|
        if raw_el["position"] == "file-start"
          global_data.before_doctype += raw_el.inner_html
        end
      end

      # Apply html_attributes via Nokogiri CSS selectors.
      # Use XML mode to avoid Nokogiri HTML parser stripping <body> attributes.
      unless global_data.html_attributes.empty?
        content_doc = Nokogiri::XML.fragment(content)
        global_data.html_attributes.each do |selector, data|
          content_doc.css(selector).each do |node|
            data.each do |attr_name, value|
              node[attr_name] = value || ""
            end
          end
        end
        content = content_doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION | Nokogiri::XML::Node::SaveOptions::AS_HTML)
      end

      # Wrap in skeleton
      content = Skeleton.call(
        before_doctype: global_data.before_doctype,
        breakpoint: global_data.breakpoint,
        content: content,
        fonts: global_data.fonts,
        media_queries: global_data.media_queries,
        head_style: global_data.head_style,
        components_head_style: global_data.components_head_style,
        head_raw: global_data.head_raw.is_a?(Array) ? global_data.head_raw : [],
        title: global_data.title,
        style: global_data.style,
        force_owa_desktop: global_data.force_owa_desktop,
        printer_support: options[:printer_support] || false,
        inline_style: global_data.inline_style,
        lang: global_data.lang,
        dir: global_data.dir
      )

      # Merge outlook conditionals
      content = MergeOutlookConditionals.call(content)

      content
    end

    # Converts a Nokogiri element to a hash matching the JS parsed format
    def self.nokogiri_to_hash(element)
      return nil unless element

      attrs = {}
      element.attributes.each { |name, attr| attrs[name] = attr.value }

      children = element.children.select(&:element?).map { |child| nokogiri_to_hash(child) }

      # For ending-tag components, content is the inner HTML
      tag_name = element.name
      component_class = Registry.find(tag_name)
      content = if component_class&.ending_tag?
        element.inner_html.strip
      else
        element.children.select(&:text?).map(&:text).join.strip
      end

      {
        tag_name: tag_name,
        attributes: attrs,
        children: children,
        content: content
      }
    end

    # Port of the JS applyAttributes function — merges global defaults, classes, etc.
    def self.apply_attributes_fn(global_data, node, parent_mj_class = "")
      return node unless node.is_a?(Hash)

      attrs = node[:attributes] || {}
      tag_name = node[:tag_name]

      # Resolve mj-class
      classes = (attrs["mj-class"] || "").split(" ")
      attributes_classes = classes.each_with_object({}) do |cls, acc|
        mj_class_values = global_data.classes[cls] || {}
        if acc["css-class"] && mj_class_values["css-class"]
          acc.merge!(mj_class_values)
          acc["css-class"] = "#{acc["css-class"]} #{mj_class_values["css-class"]}"
        else
          acc.merge!(mj_class_values)
        end
      end

      # Default attributes for parent mj-class
      default_attrs_for_classes = parent_mj_class.split(" ").each_with_object({}) do |cls, acc|
        class_defaults = global_data.classes_default.dig(cls, tag_name)
        acc.merge!(class_defaults) if class_defaults
      end

      next_parent_mj_class = attrs["mj-class"] || parent_mj_class

      # Merge: global defaults -> class attrs -> class default attrs -> element attrs (minus mj-class)
      element_attrs = attrs.reject { |k, _| k == "mj-class" }
      merged_attrs = (global_data.default_attributes[tag_name] || {})
        .merge(attributes_classes)
        .merge(default_attrs_for_classes)
        .merge(element_attrs)

      # Recurse into children
      merged_children = (node[:children] || []).map { |child|
        apply_attributes_fn(global_data, child, next_parent_mj_class)
      }

      node.merge(
        attributes: merged_attrs,
        raw_attrs: element_attrs,
        global_attributes: global_data.default_attributes["mj-all"] || {},
        children: merged_children
      )
    end

    private_class_method :nokogiri_to_hash, :apply_attributes_fn
  end
end
