# frozen_string_literal: true

module Types
  include Dry.Types()

  PROVIDER_TRACK_FORMATS = {
    fast_delivery: /\AFD\d{1,10}\z/,
    happy_package: /\AHP\d{1,10}\z/
  }.freeze

  Name = Params::String.constrained(min_size: 1, max_size: 255, format: /\A\w+\z/)
  Email = Types.Constructor(String, &:downcase).constrained(format: URI::MailTo::EMAIL_REGEXP)

  FastDeliveryTrack = Params::String.constrained(format: PROVIDER_TRACK_FORMATS[:fast_delivery])
  HappyPackageTrack = Params::String.constrained(format: PROVIDER_TRACK_FORMATS[:happy_package])
  TrackNumber = FastDeliveryTrack | HappyPackageTrack
end
