# frozen_string_literal: true

class Package::TrackingInitiatedHandler < ApplicationJob
  prepend RailsEventStore::AsyncHandler

  def perform(event)
    package = Package.find(event.data[:package_id])

    case package.provider
    when :fast_delivery
      # Subscribe to webhooks from FastDelivery service
      logger.info("Package #{package.id} subscribed to webhooks from FastDelivery")
    when :happy_package
      # Subscribe to webhooks from HappyPackage service
      logger.info("Package #{package.id} subscribed to webhooks from HappyPackage")
    end
  end
end
