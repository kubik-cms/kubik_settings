# frozen_string_literal: true

class Kubik::Setting < ApplicationRecord
  after_commit :flush_cache

  ATTRIBUTES = KubikSettings.configuration.settings || {
    example_setting: {
      default: true,
      input: :boolean,
      type: ActiveRecord::Type::Boolean
    }
  }

  store :settings_hash, accessors: ATTRIBUTES.keys

  ATTRIBUTES.each do |key, value|
    define_method key do
      settings_attribute = settings_hash[key].blank? ? value[:default] : settings_hash[key]
      value[:type].new.cast(settings_attribute)
    end
  end

  if defined?(Kubik::Metatagable)
    include Kubik::Metatagable
    kubik_metatagable
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
    Rails.cache.delete("kubik/settings")
  end
end
