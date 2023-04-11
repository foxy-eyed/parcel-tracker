# frozen_string_literal: true

module Types
  include Dry.Types()

  PROVIDERS = %w[fast_delivery happy_package].freeze
  SUBSCRIPTION_CHANNELS = %w[email phone].freeze

  PROVIDER_TRACK_FORMATS = {
    fast_delivery: /\AFD\d{1,10}\z/,
    happy_package: /\AHP\d{1,10}\z/
  }.freeze

  PHONE_FORMAT = /\A(\+?\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\z/

  Name = Params::String.constrained(min_size: 1, max_size: 255, format: /\A\w+\z/)
  Email = Types.Constructor(String, &:downcase).constrained(format: URI::MailTo::EMAIL_REGEXP)
  Phone = Params::String.constrained(format: PHONE_FORMAT)

  SubscriptionChannel = Types::String.enum(*SUBSCRIPTION_CHANNELS)
  SubscriptionChannels = Types::Array.of(SubscriptionChannel)

  FastDeliveryTrack = Params::String.constrained(format: PROVIDER_TRACK_FORMATS[:fast_delivery])
  HappyPackageTrack = Params::String.constrained(format: PROVIDER_TRACK_FORMATS[:happy_package])
  TrackNumber = FastDeliveryTrack | HappyPackageTrack
  Provider = Params::String.constrained(included_in: PROVIDERS)
end
