# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def show; end

  def create
    subscription = package_resource.subscriptions.find_or_initialize_by(subscriber: current_user)
    p subscription_params
    result = SubscriptionContract.new.call(**subscription_params)
    if result.success?
      subscription.update!(result.to_h)
      render json: subscription
    else
      render status: :unprocessable_entity, json: { errors: result.errors.to_h }
    end
  end

  private

  def package_resource
    @package_resource ||= Package.find(params[:package_id])
  end

  def subscription_params
    # params.permit(:package_id, :email, :phone, enabled: [])
    params.permit!
  end
end
