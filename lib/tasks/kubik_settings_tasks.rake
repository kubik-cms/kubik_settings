# frozen_string_literal: true

namespace :kubik_settings do
  desc "Copy legacy media AI flags from Kubik::AiConfiguration into :media resource settings (idempotent)"
  task copy_legacy_ai_media_settings: :environment do
    unless defined?(Kubik::ResourceSetting)
      puts "Kubik::ResourceSetting not available; skip."
      next
    end
    unless KubikSettings::ResourceResolver.registered?(:media)
      puts "Resource :media is not registered in KubikSettings; skip."
      next
    end
    unless defined?(Kubik::AiConfiguration)
      puts "Kubik::AiConfiguration not available; skip."
      next
    end

    record = Kubik::ResourceSetting.for(:media)
    if record.settings_hash.present? && !record.empty_settings?
      puts "Media resource settings already have values; skip."
      next
    end

    ai = Kubik::AiConfiguration.instance
    record.settings_hash = {
      "auto_analyze_on_upload" => ai.auto_analyze_on_upload,
      "auto_apply_alt_text" => ai.auto_apply_alt_text,
      "auto_apply_tags" => ai.auto_apply_tags,
      "prefer_no_faces" => ai.prefer_no_faces,
      "tag_vocabulary_hints" => ai.tag_vocabulary_hints,
      "context_media" => ai.context_media
    }
    record.save!
    puts "Copied media AI settings into kubik_resource_settings (key=media)."
  end
end
