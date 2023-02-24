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
                             "db/migrate/create_kubik_settings.rb",
                             migration_version: migration_version)
        end

        private

        def migration_version
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
      end
    end
  end
end
