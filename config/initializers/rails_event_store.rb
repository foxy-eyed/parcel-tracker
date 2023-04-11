# frozen_string_literal: true

require "rails_event_store"
require "aggregate_root"
require "arkency/command_bus"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::JSONClient.new
  Rails.configuration.command_bus = Arkency::CommandBus.new

  AggregateRoot.configure do |config|
    config.default_event_store = Rails.configuration.event_store
  end

  # Subscribe event handlers below
  Rails.configuration.event_store.tap do |store|
    store.subscribe(Package::InitTracking, to: [Package::TrackingInitiated])
    store.subscribe(Package::UpdateReadModel, to: [FastDelivery::ReceivedAtTransitLocation,
                                                   FastDelivery::DispatchedFromTransitLocation,
                                                   HappyPackage::ReceivedAtTransitLocation,
                                                   HappyPackage::DispatchedFromTransitLocation,
                                                   Package::DeliveryAttemptFailed,
                                                   Package::DeliveredToRecipient])
    store.subscribe(Package::NotifySubscribers, to: [FastDelivery::ReceivedAtTransitLocation,
                                                     FastDelivery::DispatchedFromTransitLocation,
                                                     HappyPackage::ReceivedAtTransitLocation,
                                                     HappyPackage::DispatchedFromTransitLocation,
                                                     Package::DeliveryAttemptFailed,
                                                     Package::DeliveredToRecipient])
    store.subscribe_to_all_events(RailsEventStore::LinkByEventType.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCorrelationId.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCausationId.new)
  end
end
