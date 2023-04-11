# frozen_string_literal: true

class Package::NotifySubscribers < ApplicationJob
  prepend RailsEventStore::AsyncHandler

  def perform(event)
    package = Package.find(event.data[:package_id])
    package.subscriptions.each do |subscription|
      notify_by_email(subscription.subscriber, subscription.email, event) if subscription.enabled.include?("email")
      notify_by_sms(subscription.subscriber, subscription.phone, event) if subscription.enabled.include?("phone")
    end
  end

  private

  def notify_by_email(user, email, _event)
    # TODO: call mailer
    logger.info("Sending notification to #{user.name} by email #{email}")
  end

  def notify_by_sms(user, phone, _event)
    # TODO: call sms service
    logger.info("Sending SMS to #{user.name} by phone #{phone}")
  end
end
