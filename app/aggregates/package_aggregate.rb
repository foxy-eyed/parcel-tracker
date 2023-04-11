# frozen_string_literal: true

class PackageAggregate
  include AggregateRoot

  class AlreadyTracked < StandardError; end
  class HasBeenDelivered < StandardError; end

  def initialize(id)
    @id = id
    @status = :created
  end

  def initiate_tracking(track:)
    raise AlreadyTracked unless @status == :created

    apply Package::TrackingInitiated.new(data: { package_id: @id, track: track })
  end

  def track_arrival(params:)
    raise HasBeenDelivered if @status == :delivered

    case params[:provider]
    when "fast_delivery"
      apply FastDelivery::ReceivedAtTransitLocation.new(data: { package_id: @id, params: params })
    when "happy_package"
      apply HappyPackage::ReceivedAtTransitLocation.new(data: { package_id: @id, params: params })
    end
  end

  def track_dispatched(params:)
    raise HasBeenDelivered if @status == :delivered

    case params[:provider]
    when "fast_delivery"
      apply FastDelivery::DispatchedFromTransitLocation.new(data: { package_id: @id, params: params })
    when "happy_package"
      apply HappyPackage::DispatchedFromTransitLocation.new(data: { package_id: @id, params: params })
    end
  end

  def track_delivery_attempt(params:)
    raise HasBeenDelivered if @status == :delivered

    case params
    in { provider: "fast_delivery", state: "successful" } | { provider: "happy_package", success: true }
      apply Package::DeliveredToRecipient.new(data: { package_id: @id, params: params })
    in { provider: "fast_delivery", state: "failed" } | { provider: "happy_package", success: false }
      apply Package::DeliveryAttemptFailed.new(data: { package_id: @id, params: params })
    end
  end

  on Package::TrackingInitiated do |event|
    @track = event.data[:track]
  end

  on FastDelivery::ReceivedAtTransitLocation do |event|
    @status = :at_transit_office
    @location = event.data.dig(:params, :location, :name)
  end

  on HappyPackage::ReceivedAtTransitLocation do |event|
    @status = :at_transit_office
    @location = event.data.dig(:params, :location)
  end

  on FastDelivery::DispatchedFromTransitLocation do |event|
    @status = :on_the_way
    @location = event.data.dig(:params, :location, :name)
  end

  on HappyPackage::DispatchedFromTransitLocation do |event|
    @status = :on_the_way
    @location = event.data.dig(:params, :location)
  end

  on Package::DeliveryAttemptFailed do |_event|
    @status = :unsuccessful_delivery
  end

  on Package::DeliveredToRecipient do |_event|
    @status = :delivered
    @location = nil
  end

  private

  attr_reader :track, :status, :location
end
