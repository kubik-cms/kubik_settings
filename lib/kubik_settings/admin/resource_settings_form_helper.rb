# frozen_string_literal: true

module KubikSettings
  module Admin
    module ResourceSettingsFormHelper
      def kubik_resource_setting_form_fields(form, definition, **_options)
        definition.form_tabs.each do |tab_def|
          form.inputs tab_def[:label] do
            Array(tab_def[:keys]).each do |key|
              meta = definition.setting_meta(key)
              next unless meta

              input_html = {}
              input_html[:hint] = meta[:hint] if meta[:hint].present?
              unless meta[:input] == :boolean
                input_html[:value] = form.object.public_send(key)
              end
              form.input key, as: meta[:input], input_html: input_html
            end
          end
        end
        nil
      end
    end
  end
end
