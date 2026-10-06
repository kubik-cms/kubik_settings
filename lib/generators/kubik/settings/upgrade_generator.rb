# frozen_string_literal: true

require "rails/generators/active_record"

module Kubik
  module Generators
    module Settings
      class UpgradeGenerator < ActiveRecord::Generators::Base
        source_root File.expand_path("templates", __dir__)
        desc "Upgrade Kubik Settings (resource settings migration and example initializer snippet)"

        def resource_settings_migration
          resource_migration = Dir.glob("db/migrate/*_create_kubik_resource_settings.rb").first
          if resource_migration
            say_status :skip, "kubik_resource_settings migration already present (#{resource_migration})"
            return
          end

          migration_template(
            "migrations/create_kubik_resource_settings.rb.erb",
            "db/migrate/create_kubik_resource_settings.rb",
            migration_version: migration_version
          )
        end

        def resource_settings_initializer_example
          target = "config/initializers/kubik_settings.resource_settings.rb.example"
          if File.exist?(target)
            say_status :skip, "#{target} already exists"
            return
          end

          template("initializers/kubik_settings_resource_settings.rb.example", target)
        end

        private

        def migration_version
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
      end
    end
  end
end
