# frozen_string_literal: true

class PackageContract < Dry::Validation::Contract
  params do
    required(:track).filled(Types::TrackNumber)
  end
end
