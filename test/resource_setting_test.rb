# frozen_string_literal: true

require "test_helper"

class ResourceSettingTest < ActiveSupport::TestCase
  setup do
    KubikSettings.configure do |config|
      config.resource_registry.clear
      config.register_resource :test_resource,
                               settings: {
                                 enabled: {
                                   default: true,
                                   input: :boolean,
                                   type: ActiveRecord::Type::Boolean
                                 },
                                 title: {
                                   default: "Default",
                                   input: :string,
                                   type: ActiveRecord::Type::String
                                 }
                               },
                               fallbacks: {
                                 title: -> { "Fallback" }
                               }
    end
  end

  test "for creates row by key" do
    record = Kubik::ResourceSetting.for(:test_resource)
    assert_equal "test_resource", record.key
    assert record.persisted?
  end

  test "resolver uses schema default then fallback" do
    assert_equal true, KubikSettings::ResourceResolver.get(:test_resource, :enabled)
    assert_equal "Fallback", KubikSettings::ResourceResolver.get(:test_resource, :title)
  end

  test "resolver uses stored value" do
    record = Kubik::ResourceSetting.for(:test_resource)
    record.update!(settings_hash: { "title" => "Stored" })
    assert_equal "Stored", KubikSettings::ResourceResolver.get(:test_resource, :title)
  end

  test "resolver stores boolean false" do
    record = Kubik::ResourceSetting.for(:test_resource)
    record.update!(settings_hash: { "enabled" => false })
    assert_equal false, KubikSettings::ResourceResolver.get(:test_resource, :enabled)
  end
end
