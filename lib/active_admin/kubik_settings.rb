ActiveAdmin.register Kubik::Setting do
  menu label: 'Settings'

  permit_params do
    permitted = Kubik::Setting::ATTRIBUTES.keys + [:settings]
    if defined?(Kubik::PermitAdditionalMetatagableAdminParams)
      Kubik::PermitAdditionalMetatagableAdminParams.push_to_params(Kubik::Setting, permitted)
    end
    permitted
  end

  show do
    tabs do
      tab "Settings" do
        attributes_table_for resource do
          Kubik::Setting::ATTRIBUTES.each do |key, _values|
            row key, ->{ resource.send(key) }
          end
        end
      end
      if resource.respond_to?(:meta_tag)
        tab "Meta" do
          render "admin/show/meta_tag_seo_helper", resource: resource
          render "admin/show/meta_tag_social_helper", resource: resource
        end
      end
    end
  end

  form do |f|
    tabs do
      tab "Settings" do
        inputs do
          f.input :settings_hash, as: :hidden, input_html: { id: "settings" }
          Kubik::Setting::ATTRIBUTES.each do |key, values|
            input_html = {}
            input_html.merge!({ value: f.object.send(key) })   if values[:input] != :boolean
            input_html.merge!({ checked: f.object.send(key) }) if values[:input] == :boolean && f.object.send(key)
            f.input key, as: values[:input], input_html: input_html
          end
        end
      end
      if f.object.respond_to?(:meta_tag)
        tab "Meta" do
          render "admin/form/meta_tag_seo_helper", f: f
          render "admin/form/meta_tag_social_helper", f: f
        end
      end
    end
    actions
  end

  controller do
    actions :all, except: %i[create new destroy]

    def find_resource
      Kubik::Setting.instance
    end

    def index
      redirect_to admin_kubik_setting_path(1)
    end

    def update
      merged_params = Kubik::Setting::ATTRIBUTES.keys.map do |key|
        [key, params[:setting][key]]
      end.to_h
      params[:setting][:settings_hash] = JSON.parse(merged_params.to_json)
      super
    end
  end
end
