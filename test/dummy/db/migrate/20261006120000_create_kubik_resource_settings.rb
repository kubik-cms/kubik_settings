# frozen_string_literal: true

class CreateKubikResourceSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :kubik_resource_settings do |t|
      t.string :key, null: false
      t.jsonb :settings_hash, null: false, default: {}
      t.timestamps
    end

    add_index :kubik_resource_settings, :key, unique: true
  end
end
