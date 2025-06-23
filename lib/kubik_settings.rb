# frozen_string_literal: true

require "inherited_resources"
require "active_admin"
require "kubik_settings/version"

module KubikSettings
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= ::Kubik::Settings::Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.ensure_configuration
    configuration
  end

  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace KubikSettings

      # Add app/models to autoload paths
      config.autoload_paths += Dir["#{File.dirname(__FILE__)}/app/models"]

      initializer :kubik_settings_configuration, before: :load_config_initializers do
        # Ensure configuration is available early
        KubikSettings.ensure_configuration
      end

      initializer :kubik_settings do
        ActiveAdmin.application.load_paths += Dir["#{File.dirname(__FILE__)}/active_admin"]
      end

      initializer :kubik_settings_active_admin, after: :kubik_settings do
        require "active_admin/kubik_settings"
      end
    end
  end
end

module Kubik
  require "kubik/settings/configuration"
  require "kubik/settings"
end
