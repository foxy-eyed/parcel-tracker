# frozen_string_literal: true

class Package::UpdateReadModel < ApplicationJob
  prepend RailsEventStore::AsyncHandler

  def perform(event)
    package = Package.find(event.data[:package_id])
    event_params = (event.data[:params] || {}).deep_symbolize_keys
    handle(package, event.class.name, event_params)
  end

  private

  def handle(package, event_class, event_params)
    case event_class
    when "FastDelivery::ReceivedAtTransitLocation"
      handle_arrived(package, event_params.dig(:location, :name), event_params.slice(:time, :weight))
    when "HappyPackage::ReceivedAtTransitLocation"
      handle_arrived(package, event_params[:location], event_params.slice(:time, :weight))
    when "FastDelivery::DispatchedFromTransitLocation"
      handle_dispatched(package, event_params.dig(:location, :name), event_params.slice(:time, :weight))
    when "HappyPackage::DispatchedFromTransitLocation"
      handle_dispatched(package, event_params[:location], event_params.slice(:time, :weight))
    when "Package::DeliveryAttemptFailed"
      handle_delivery_failed(package)
    when "Package::DeliveredToRecipient"
      handle_delivered(package)
    end
  end

  def handle_arrived(package, location, properties)
    package.update!(
      status: :at_transit_office,
      location: location,
      properties: properties
    )
  end

  def handle_dispatched(package, location, properties)
    package.update!(
      status: :on_the_way,
      location: location,
      properties: properties
    )
  end

  def handle_delivery_failed(package)
    package.update!(status: :unsuccessful_delivery)
  end

  def handle_delivered(package)
    package.update!(status: :delivered, location: nil)
  end
end
