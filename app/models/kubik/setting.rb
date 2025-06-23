# frozen_string_literal: true

class Kubik::Setting < ActiveRecord::Base
  after_commit :flush_cache

  # Ensure configuration is available before defining ATTRIBUTES
  def self.ensure_configuration
    ::KubikSettings.ensure_configuration
  end

  ATTRIBUTES = begin
    ensure_configuration
    ::KubikSettings.configuration.settings || {
      example_setting: {
        default: true,
        input: :boolean,
        type: ActiveRecord::Type::Boolean
      }
    }
  end

  # Use store method with Rails 7+ compatibility
  if Rails.version.to_f >= 7.0
    store :settings_hash, accessors: ATTRIBUTES.keys, coder: JSON
  else
    store :settings_hash, accessors: ATTRIBUTES.keys
  end

  ATTRIBUTES.each do |key, value|
    define_method key do
      settings_attribute = settings_hash[key].blank? && !self.persisted? ? value[:default] : settings_hash[key]
      value[:type].new.cast(settings_attribute)
    end
  end

  # Conditionally include metatag functionality only if the required table exists
  if defined?(Kubik::Metatagable)
    begin
      # Check if the meta tags table exists before including the module
      if table_exists? && connection.table_exists?('kubik_meta_tags')
        include Kubik::Metatagable
        kubik_metatagable
      end
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid => e
      # Silently skip metatag functionality if database/table doesn't exist
      Rails.logger.warn "Kubik::Metatagable not included: #{e.message}" if Rails.logger
    end
  end

  def self.table_name
    ensure_configuration
    ::KubikSettings.configuration.table_name
  end

  def self.cached
    Rails.cache.fetch("kubik-settings") { instance }
  end

  def self.instance
    first_or_create!(singleton_guard: 1)
  end

  def to_s
    "Settings"
  end

  private

  def flush_cache
    Rails.cache.delete("kubik-settings")
  end
end
