# frozen_string_literal: true

class Package < ApplicationRecord
  has_many :subscriptions
  has_many :subscribers, through: :subscriptions

  def provider
    Types::PROVIDER_TRACK_FORMATS.each do |provider, track_format|
      return provider if track_format.match?(track)
    end

    nil
  end
end
