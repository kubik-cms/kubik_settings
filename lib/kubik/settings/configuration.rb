# frozen_string_literal: true

require_relative "resource_definition"

module Kubik
  module Settings
    class Configuration
      attr_accessor :settings, :table_name, :menu_options, :active_admin_blocks, :resource_class_map

      def initialize
        @table_name = 'kubik_settings'
        @menu_options = {}
        @active_admin_blocks = []
        @resource_registry = {}
        @resource_class_map = {}
      end

      def resource_registry
        @resource_registry
      end

      def register_resource(key, label: nil, index_resource: nil, index_path_helper: nil, tabs: nil, settings: {},
                            fallbacks: {}, admin_as: nil)
        definition = ResourceDefinition.new(
          key: key,
          label: label,
          index_resource: index_resource,
          index_path_helper: index_path_helper,
          tabs: tabs,
          settings: settings,
          fallbacks: fallbacks,
          admin_as: admin_as
        )
        @resource_registry[definition.key] = definition
        definition
      end

      def add_resource_active_admin_block(resource_key, &block)
        key = resource_key.to_s
        definition = @resource_registry[key]
        raise KubikSettings::Error, "Unknown resource setting :#{key}" unless definition

        definition.add_active_admin_block(&block)
      end

      def add_active_admin_block(&block)
        @active_admin_blocks << block
      end
    end
  end
end
