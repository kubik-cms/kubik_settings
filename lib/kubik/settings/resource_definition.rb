# frozen_string_literal: true

module Kubik
  module Settings
    class ResourceDefinition
      attr_reader :key,
                  :label,
                  :index_resource,
                  :index_path_helper,
                  :tabs,
                  :settings,
                  :fallbacks,
                  :admin_as,
                  :active_admin_blocks,
                  :display

      def initialize(key:, label: nil, index_resource: nil, index_path_helper: nil, tabs: nil, settings: {},
                     fallbacks: {}, admin_as: nil, active_admin_blocks: [], display: :page)
        @key = key.to_s
        @label = label || "#{@key.humanize} settings"
        @index_resource = index_resource
        @index_path_helper = index_path_helper
        @tabs = tabs
        @settings = normalize_settings(settings)
        @fallbacks = fallbacks || {}
        @admin_as = admin_as || "#{@key.camelize}ResourceSetting"
        @active_admin_blocks = active_admin_blocks
        @display = display.to_sym
      end

      def offcanvas?
        @display == :offcanvas
      end

      def page?
        @display == :page
      end

      def setting_keys
        @settings.keys
      end

      def setting_meta(key)
        @settings[key.to_sym] || @settings[key.to_s]
      end

      def route_resource_name
        @admin_as.underscore.pluralize
      end

      def form_tabs
        return @tabs if @tabs.present?

        [{ label: "Settings", keys: setting_keys }]
      end

      def add_active_admin_block(&block)
        @active_admin_blocks << block
      end

      private

      def normalize_settings(settings)
        settings.each_with_object({}) do |(name, meta), acc|
          acc[name.to_sym] = meta
        end
      end
    end
  end
end
