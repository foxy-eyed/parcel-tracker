# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    enable_extension "pgcrypto"

    create_table :users, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
