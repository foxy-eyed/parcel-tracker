# frozen_string_literal: true

class PackageAggregate
  include AggregateRoot

  AlreadyTracked = Class.new(StandardError)

  def initialize(id)
    @id = id
    @state = :created
  end

  def initiate_tracking
    raise AlreadyTracked unless @state == :created

    apply Package::TrackingInitiated.new(data: { package_id: @id })
  end

  on Package::TrackingInitiated do |_event|
    @state = :tracking_initiated
  end
end
