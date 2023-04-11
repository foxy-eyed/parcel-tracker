# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def index
    subscription = package_resource.subscriptions.find_by(subscriber: current_user)
    render json: subscription, only: %i[email phone enabled]
  end

  def create
    subscription = package_resource.subscriptions.find_or_initialize_by(subscriber: current_user)
    result = SubscriptionContract.new.call(**subscription_params)
    if result.success?
      subscription.update!(result.to_h)
      render json: subscription, only: %i[email phone enabled]
    else
      render status: :unprocessable_entity, json: { errors: result.errors.to_h }
    end
  end

  private

  def package_resource
    @package_resource ||= Package.find(params[:package_id])
  end

  def subscription_params
    params.permit(:package_id, :email, :phone, enabled: [])
  end
end
