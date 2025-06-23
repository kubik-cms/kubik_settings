# frozen_string_literal: true

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

  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace KubikSettings

      initializer :kubik_settings do
        ActiveAdmin.application.load_paths += Dir["#{File.dirname(__FILE__)}/active_admin"]
      end
    end
  end
end

module Kubik
  require "kubik/settings/configuration"
  require "kubik/settings"
end
