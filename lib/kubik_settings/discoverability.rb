# frozen_string_literal: true

module KubikSettings
  module Discoverability
    # Suggested keys for host `KubikSettings.configure` (stored in settings_hash).
    SETTING_KEYS = %i[
      crawler_policy
      crawler_catalog_sync
      robots_txt_mode
      robots_txt_generated
      robots_txt_body
      robots_txt_lock_custom
      robots_block_admin_paths
      robots_txt_extra_paths
      sitemap_url
      llms_txt_body
      llms_txt_include_policy_summary
      llms_txt_ai_draft
      schema_organization
      schema_website
    ].freeze

    module_function

    def default_settings_hash
      {
        "crawler_policy" => { "matrix" => {}, "custom_bots" => [] },
        "robots_txt_mode" => "generated",
        "robots_txt_lock_custom" => false,
        "robots_block_admin_paths" => true,
        "llms_txt_include_policy_summary" => true,
        "schema_organization" => {},
        "schema_website" => {}
      }
    end
  end
end
