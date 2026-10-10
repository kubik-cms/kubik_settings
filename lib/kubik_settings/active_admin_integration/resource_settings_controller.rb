# frozen_string_literal: true

module KubikSettings
  module ActiveAdminIntegration
    module ResourceSettingsController
      extend ActiveSupport::Concern

      included do
        helper KubikSettings::Admin::ResourceSettingsFormHelper
        prepend_view_path ::KubikSettings::Rails::Engine.root.join("app/views")
      end

      def edit
        if resource_setting_definition.offcanvas?
          return render_offcanvas if turbo_frame_request?

          redirect_to resource_setting_index_url
        else
          super
        end
      end

      def update
        settings_hash = merged_settings_hash
        merge_settings_hash_param!(settings_hash)

        if render_offcanvas_form?
          if resource.update(settings_hash: settings_hash)
            kubik_ai_enqueue_missed_media_analysis if resource_setting_key.to_s == "media"
            render_offcanvas(close_offcanvas: true)
          else
            render_offcanvas(status: :unprocessable_entity)
          end
        else
          update! location: resource_setting_index_url
        end
      end

      def render_offcanvas(notice: nil, status: :ok, close_offcanvas: false)
        body = ::ApplicationController.render(
          template: "kubik_settings/admin/resource_settings/offcanvas",
          layout: false,
          locals: offcanvas_locals(notice: notice, close_offcanvas: close_offcanvas)
        )
        render html: body, layout: false, status: status
      end

      def offcanvas_locals(notice: nil, close_offcanvas: false)
        {
          resource: resource,
          definition: resource_setting_definition,
          param_key: active_admin_config.param_key,
          notice: notice,
          close_offcanvas: close_offcanvas
        }
      end

      private

      def merged_settings_hash
        param_key = active_admin_config.param_key
        raw = params[param_key] || {}
        KubikSettings::ResourceResolver.build_settings_hash(resource_setting_definition, raw)
      end

      def merge_settings_hash_param!(settings_hash)
        param_key = active_admin_config.param_key
        params[param_key] = ActionController::Parameters.new(
          settings_hash: settings_hash
        ).permit(settings_hash: {})
      end

      def render_offcanvas_form?
        return false unless resource_setting_definition.offcanvas?

        frame_id = request.headers["Turbo-Frame"].presence
        frame_id == "kubik_offcanvas_frame" || turbo_frame_request?
      end

      def resource_setting_index_url
        KubikSettings::ResourceResolver.index_path(resource_setting_key) || admin_root_path
      end

      def kubik_ai_enqueue_missed_media_analysis
        return unless defined?(KubikAi::Media::MissedAnalysis)
        return unless ActiveModel::Type::Boolean.new.cast(
          KubikSettings::ResourceResolver.get(:media, :auto_analyze_on_upload)
        )

        Kubik::MediaUpload
          .where(aasm_state: "ready")
          .where.not(image_data: nil)
          .order(id: :desc)
          .limit(30)
          .find_each do |upload|
            KubikAi::Media::MissedAnalysis.enqueue_if_eligible!(upload)
          end
      end
    end
  end
end
