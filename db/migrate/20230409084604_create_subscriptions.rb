# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.references :package, type: :uuid, null: false, foreign_key: true
      t.references :subscriber, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :email
      t.string :phone
      t.string :enabled, array: true, null: false, default: []
      t.timestamps
    end

    add_index :subscriptions, %i[package_id subscriber_id], unique: true
  end
end
