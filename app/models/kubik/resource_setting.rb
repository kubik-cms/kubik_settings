# frozen_string_literal: true

class Kubik::ResourceSetting < ActiveRecord::Base
  self.table_name = "kubik_resource_settings"

  validates :key, presence: true, uniqueness: true

  after_commit :flush_cache

  def self.register_setting_accessors!
    return if @setting_accessors_registered

    KubikSettings.ensure_configuration
    KubikSettings.configuration.resource_registry.each_value do |definition|
      definition.setting_keys.each { |setting_key| register_setting_accessor(setting_key) }
    end
    @setting_accessors_registered = true
  end

  def self.register_setting_accessor(setting_key)
    key_sym = setting_key.to_sym
    return if @registered_setting_accessors&.include?(key_sym)

    @registered_setting_accessors ||= Set.new
    @registered_setting_accessors << key_sym

    meta = KubikSettings.configuration.resource_registry.values
      .map { |definition| definition.setting_meta(key_sym) }
      .compact
      .first
    type = meta&.dig(:type)
    attribute_type = type.is_a?(Class) ? type.new : ActiveModel::Type::Value.new
    attribute key_sym, type: attribute_type

    define_method(key_sym) do
      return super() unless definition.setting_keys.include?(key_sym)

      KubikSettings::ResourceResolver.get(key, key_sym)
    end

    define_method(:"#{key_sym}=") do |value|
      return super(value) unless definition.setting_keys.include?(key_sym)

      write_setting!(key_sym, value)
    end
  end

  def self.for(resource_key)
    register_setting_accessors!
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

  def setting_key_stored?(setting_key)
    name = setting_key.to_s
    hash = settings_hash || {}
    hash.key?(name) || hash.key?(setting_key.to_sym)
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
