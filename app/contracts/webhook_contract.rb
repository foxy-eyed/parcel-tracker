# frozen_string_literal: true

class WebhookContract < Dry::Validation::Contract
  params do
    required(:provider).filled(Types::Provider)
    required(:track).filled(Types::TrackNumber)
  end
end
