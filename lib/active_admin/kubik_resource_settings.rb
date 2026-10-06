# frozen_string_literal: true

module ActiveAdmin
  module KubikResourceSettings
    class BaseResource
      class << self
        def register_all!
          ::KubikSettings.ensure_configuration
          require_relative "../../app/models/kubik/resource_setting"

          ::KubikSettings.configuration.resource_registry.each_value do |definition|
            register_one!(definition)
          end
        end

        def register_one!(definition)
          setting_key = definition.key
          admin_as = definition.admin_as

          return if already_registered?(admin_as)

          ::ActiveAdmin.register Kubik::ResourceSetting, as: admin_as do
            menu false
            actions :all, except: %i[create new destroy]

            permit_params do
              keys = definition.setting_keys.map(&:to_sym)
              keys + [settings_hash: keys]
            end

            breadcrumb do
              crumbs = [link_to("Admin", admin_root_path)]
              if definition.index_path_helper.present?
                crumbs << link_to(definition.label.sub(/ settings\z/i, ""), public_send(definition.index_path_helper))
              end
              crumbs << definition.label
              crumbs
            end

            controller do
              define_method(:resource_setting_definition) { definition }
              define_method(:resource_setting_key) { setting_key }

              def find_resource
                Kubik::ResourceSetting.for(resource_setting_key)
              end

              def index
                redirect_to action: :edit, id: find_resource.id
              end

              def update
                param_key = active_admin_config.param_key
                raw = params[param_key] || {}
                merged = resource_setting_definition.setting_keys.index_with do |key|
                  raw[key.to_s]
                end
                params[param_key][:settings_hash] = JSON.parse(merged.to_json)
                super
              end
            end

            show do
              redirect_to action: :edit, id: resource.id
            end

            form do |f|
              tabs do
                resource_setting_definition.form_tabs.each do |tab_def|
                  tab tab_def[:label] do
                    f.inputs do
                      f.input :settings_hash, as: :hidden, input_html: { id: "resource_settings_#{setting_key}" }
                      Array(tab_def[:keys]).each do |key|
                        meta = resource_setting_definition.setting_meta(key)
                        next unless meta

                        input_html = { hint: meta[:hint] }
                        if meta[:input] == :boolean
                          input_html[:checked] = f.object.public_send(key)
                        else
                          input_html[:value] = f.object.public_send(key)
                        end
                        f.input key, as: meta[:input], input_html: input_html
                      end
                    end
                  end
                end
              end
              f.actions
            end

            definition.active_admin_blocks.each do |block|
              instance_eval(&block)
            end
          end
        end

        def already_registered?(admin_as)
          namespace = ::ActiveAdmin.application.namespace(:admin)
          namespace.resources.any? { |resource| resource.resource_name.name == admin_as }
        rescue StandardError
          false
        end
      end
    end
  end
end

Rails.application.config.after_initialize do
  ActiveAdmin::KubikResourceSettings::BaseResource.register_all!
end
