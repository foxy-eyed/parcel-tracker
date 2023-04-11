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
    in { provider: "fast_delivery", state: "successful" }
      apply FastDelivery::DeliveredToRecipient.new(data: { package_id: @id, params: params })
    in { provider: "fast_delivery", state: "failed" }
      apply FastDelivery::DeliveryAttemptFailed.new(data: { package_id: @id, params: params })
    in { provider: "happy_package", success: true }
      apply HappyPackage::DeliveredToRecipient.new(data: { package_id: @id, params: params })
    in { provider: "happy_package", success: false }
      apply HappyPackage::DeliveryAttemptFailed.new(data: { package_id: @id, params: params })
    end
  end

  on Package::TrackingInitiated do |event|
    @track = event.data[:track]
  end

  on FastDelivery::ReceivedAtTransitLocation do |event|
    @status = :at_transit_office
    @location = event.data.dig(:params, :location)
  end

  on HappyPackage::ReceivedAtTransitLocation do |event|
    @status = :at_transit_office
    @location = event.data.dig(:params, :location, :name)
  end

  on FastDelivery::DispatchedFromTransitLocation do |event|
    @status = :on_the_way
    @location = event.data.dig(:params, :location)
  end

  on HappyPackage::DispatchedFromTransitLocation do |event|
    @status = :on_the_way
    @location = event.data.dig(:params, :location, :name)
  end

  on FastDelivery::DeliveryAttemptFailed, HappyPackage::DeliveryAttemptFailed do |_event|
    @status = :unsuccessful_delivery
  end

  on FastDelivery::DeliveredToRecipient, HappyPackage::DeliveredToRecipient do |_event|
    @status = :delivered
    @location = nil
  end

  private

  attr_reader :track, :status, :location
end
