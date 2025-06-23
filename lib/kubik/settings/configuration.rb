# frozen_string_literal: true

module Kubik
  module Settings
    class Configuration
      attr_accessor :settings, :table_name

      def initialize
        @table_name = 'kubik_settings'
      end
    end
  end
end
