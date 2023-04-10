# frozen_string_literal: true

class PackageRepository
  def initialize(event_store = Rails.configuration.event_store)
    @repository = AggregateRoot::Repository.new(event_store)
  end

  def with_package(id, &)
    stream_name = "package$#{id}"
    @repository.with_aggregate(PackageAggregate.new(id), stream_name, &)
  end
end
