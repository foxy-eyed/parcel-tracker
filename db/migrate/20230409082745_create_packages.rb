# frozen_string_literal: true

class CreatePackages < ActiveRecord::Migration[7.0]
  def change
    create_table :packages, id: :uuid do |t|
      t.string :track, null: false, index: true, unique: true
      t.string :status, null: false, default: "created"
      t.string :location
      t.jsonb :properties, null: false, default: {}

      t.timestamps
    end
  end
end
