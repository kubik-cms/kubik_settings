# frozen_string_literal: true

class Kubik::ResourceSetting < ActiveRecord::Base
  self.table_name = "kubik_resource_settings"

  validates :key, presence: true, uniqueness: true

  after_commit :flush_cache

  def self.for(resource_key)
    key = resource_key.to_s
    definition = KubikSettings.configuration.resource_registry[key]
    raise KubikSettings::Error, "Resource setting :#{key} is not registered" unless definition

    find_or_create_by!(key: key)
  end

  def self.cached(resource_key)
    key = resource_key.to_s
    Rails.cache.fetch("kubik/resource_settings/#{key}") { self.for(key) }
  end

  def definition
    KubikSettings.configuration.resource_registry[key] ||
      raise(KubikSettings::Error, "Resource setting :#{key} is not registered")
  end

  def setting_keys
    definition.setting_keys
  end

  def raw_stored_value(setting_key)
    name = setting_key.to_s
    hash = settings_hash || {}
    return hash[name] if hash.key?(name)

    hash[setting_key.to_sym]
  end

  def write_setting!(setting_key, value)
    name = setting_key.to_s
    self.settings_hash = (settings_hash || {}).merge(name => value)
  end

  def [](setting_key)
    KubikSettings::ResourceResolver.get(key, setting_key)
  end

  def empty_settings?
    settings_hash.blank? || settings_hash.values.all? { |v| v.nil? || v == "" }
  end

  def to_s
    definition.label
  end

  def respond_to_missing?(method, include_private = false)
    setting_keys.include?(method.to_sym) || super
  end

  def method_missing(method, *args, &block)
    if setting_keys.include?(method.to_sym) && args.empty?
      KubikSettings::ResourceResolver.get(key, method)
    else
      super
    end
  end

  private

  def flush_cache
    Rails.cache.delete("kubik/resource_settings/#{key}")
  end
end
