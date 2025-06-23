# frozen_string_literal: true

require "rails/generators/active_record"

module Kubik
  module Generators
    module Settings
      class InstallGenerator < ActiveRecord::Generators::Base
        source_root File.expand_path("templates", __dir__)
        desc "Running Kubik Settings generators"
        argument :name, type: :string, default: "kubik"

        def db_migrations
          migration_template("migrations/create_kubik_settings.rb.erb",
                             "db/migrate/create_#{table_name}.rb",
                             migration_version: migration_version,
                             table_name: table_name)
        end

        def active_admin_resource
          template("active_admin/kubik_settings.rb.erb",
                   "app/admin/kubik_settings.rb")
        end

        def configuration_initializer
          template("initializers/kubik_settings.rb.erb",
                   "config/initializers/kubik_settings.rb")
        end

        private

        def table_name
          # Ensure configuration is available, fallback to default if not
          begin
            require "kubik_settings"
            KubikSettings.ensure_configuration
            KubikSettings.configuration.table_name
          rescue => e
            # Fallback to default table name if configuration is not available
            "kubik_settings"
          end
        end

        def migration_version
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
      end
    end
  end
end
