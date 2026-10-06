# frozen_string_literal: true

module KubikSettings
  class ResourceResolver
    SCOPE_TO_SETTING_KEY = {
      media: :context_media,
      seo: :context_seo,
      social: :context_social
    }.freeze

    class << self
      def registered?(resource_key)
        configuration.resource_registry.key?(resource_key.to_s)
      end

      def get(resource_key, setting_key, use_schema_default: true)
        return nil unless registered?(resource_key)

        record = Kubik::ResourceSetting.for(resource_key)
        definition = configuration.resource_registry[resource_key.to_s]
        meta = definition.setting_meta(setting_key)
        return nil unless meta

        stored = record.raw_stored_value(setting_key)
        unless stored_unset?(stored, meta)
          return cast_value(meta, stored)
        end

        fallback = definition.fallbacks[setting_key.to_sym] || definition.fallbacks[setting_key.to_s]
        if fallback.respond_to?(:call)
          fallback_value = fallback.call
          return cast_value(meta, fallback_value) unless fallback_value.nil?
        end

        return nil unless use_schema_default

        cast_value(meta, meta[:default])
      end

      def get_stored_or_fallback_only(resource_key, setting_key)
        get(resource_key, setting_key, use_schema_default: false)
      end

      def context_for_scope(resource_key, scope)
        setting_key = SCOPE_TO_SETTING_KEY[scope.to_sym]
        return nil unless setting_key

        text = get(resource_key, setting_key).to_s.strip
        text.presence
      end

      def resource_key_for(record_or_class)
        name = if record_or_class.is_a?(Class)
                 record_or_class.name
               else
                 record_or_class.class.name
               end
        map = configuration.resource_class_map
        map[name] || map[name.to_sym]
      end

      def edit_path(resource_key, **url_options)
        definition = configuration.resource_registry[resource_key.to_s]
        raise KubikSettings::Error, "Unknown resource setting #{resource_key}" unless definition

        record = Kubik::ResourceSetting.for(resource_key)
        helper = "edit_admin_#{definition.admin_as.underscore}_path"
        ::Rails.application.routes.url_helpers.public_send(helper, record, **url_options)
      end

      private

      def configuration
        KubikSettings.configuration
      end

      def stored_unset?(stored, meta)
        return true if stored.nil?
        return false if meta[:input] == :boolean

        stored.blank?
      end

      def cast_value(meta, value)
        type = meta[:type]
        return value if type.nil?

        type.new.cast(value)
      end
    end
  end
end
