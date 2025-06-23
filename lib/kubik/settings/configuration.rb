# frozen_string_literal: true

module Kubik
  module Settings
    class Configuration
      attr_accessor :settings, :table_name, :menu_options, :active_admin_blocks

      def initialize
        @table_name = 'kubik_settings'
        @menu_options = {}
        @active_admin_blocks = []
      end

      def add_active_admin_block(&block)
        @active_admin_blocks << block
      end
    end
  end
end
