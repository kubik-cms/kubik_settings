# frozen_string_literal: true

require "kubik_settings/version"
require "kubik_settings/railtie"

module KubikSettings
  class Error < StandardError; end
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace KubikSettings

      initializer :kubik_settings do
        ActiveAdmin.application.load_paths += Dir["#{File.dirname(__FILE__)}/active_admin"]
      end
    end
  end
end
