# frozen_string_literal: true

module KubikSettings
  module ActiveAdminIntegration
    class IndexSettingsLinks
      class << self
        def apply!
          return unless defined?(::ActiveAdmin)

          ::KubikSettings.ensure_configuration
          ::KubikSettings.configuration.resource_registry.each_value do |definition|
            apply_link!(definition)
          end
        end

        def apply_link!(definition)
          return if definition.index_resource.blank?

          klass = definition.index_resource.constantize
          config = ::ActiveAdmin.application.namespace(:admin).resource_for(klass)
          unless config
            ::Rails.logger.warn("[KubikSettings] ActiveAdmin resource not found for #{definition.index_resource}")
            return
          end

          setting_key = definition.key
          config.dsl.class_eval do
            action_item :"kubik_resource_settings_#{setting_key}", only: :index, priority: 0 do
              link_to "Settings", KubikSettings::ResourceResolver.edit_path(setting_key)
            end
          end
        rescue NameError => e
          ::Rails.logger.warn("[KubikSettings] Skipped index settings link for #{definition.key}: #{e.message}")
        end
      end
    end
  end
end
