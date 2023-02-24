ActiveAdmin.register Kubik::Setting do
  permit_params do
    permitted = [:settings_hash]
    if defined?(Kubik::PermitAdditionalMetatagableAdminParams)
      Kubik::PermitAdditionalMetatagableAdminParams.push_to_params(Kubik::Setting, permitted)
    end
    permitted
  end

  show do
    tabs do
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
  end
end
