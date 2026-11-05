# frozen_string_literal: true

module KubikSettings
  # Shared Kubik frontend layout assigns (settings + optional navigation hooks).
  # Host apps extend `kubik_frontend_view_assigns_for` for previewable records.
  module FrontendViewContext
    extend ActiveSupport::Concern

    included do
      before_action :set_kubik_frontend_assigns if respond_to?(:before_action)
    end

    def set_kubik_frontend_assigns
      @kubik_settings = self.class.fetch_kubik_settings
      @slickr_settings = @kubik_settings
      @slickr_nav_helper = self.class.fetch_navigation_helper
      @kubik_meta_override = nil
      @slickr_meta_override = nil
    end

    class_methods do
      def kubik_frontend_view_assigns(record)
        {
          kubik_settings: fetch_kubik_settings,
          slickr_nav_helper: fetch_navigation_helper,
          kubik_navigation: fetch_kubik_navigation
        }.merge(kubik_frontend_view_assigns_for(record))
      end

      def fetch_kubik_settings
        Kubik::Setting.cached_settings_hash
      end

      def fetch_kubik_navigation
        return [] unless defined?(Kubik::Navigation) && Kubik::Navigation.respond_to?(:cached_main_menu_children)

        Kubik::Navigation.cached_main_menu_children
      end

      def fetch_navigation_helper
        return { nav_menus: {} } unless defined?(Kubik::Navigation) && Kubik::Navigation.respond_to?(:all_nav_menus)

        { nav_menus: Kubik::Navigation.all_nav_menus }
      rescue StandardError
        { nav_menus: {} }
      end

      def kubik_frontend_view_assigns_for(_record)
        {}
      end
    end
  end
end
