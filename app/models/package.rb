# frozen_string_literal: true

class Package < ApplicationRecord
  has_many :subscriptions
  has_many :subscribers, through: :subscriptions
end
