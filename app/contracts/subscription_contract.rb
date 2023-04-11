# frozen_string_literal: true

class SubscriptionContract < Dry::Validation::Contract
  params do
    optional(:email).maybe(Types::Email)
    optional(:phone).maybe(Types::Phone)
    required(:enabled).filled(Types::SubscriptionChannels)
  end

  rule do
    base.failure("You must specify email or phone") unless values.values_at(:email, :phone).any?
  end
end
