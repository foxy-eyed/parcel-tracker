# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :subscriber, class_name: "User"
  belongs_to :package
end
