# frozen_string_literal: true

class WebhooksController < ApplicationController
  def arrived
    with_package_from_payload do |package|
      PackageRepository.new.with_package(package.id) do |package_agg|
        package_agg.track_arrival(params: webhook_params)
      end
      head :ok
    end
  end

  def dispatched
    with_package_from_payload do |package|
      PackageRepository.new.with_package(package.id) do |package_agg|
        package_agg.track_dispatched(params: webhook_params)
      end
      head :ok
    end
  end

  def delivery_attempted
    with_package_from_payload do |package|
      PackageRepository.new.with_package(package.id) do |package_agg|
        package_agg.track_delivery_attempt(params: webhook_params)
      end
      head :ok
    end
  end

  private

  def with_package_from_payload
    result = WebhookContract.new.call(**webhook_params)
    if result.success?
      package = Package.find_by!(track: result[:track])
      if package
        yield package
      else
        head :not_found
      end
    else
      render status: :unprocessable_entity, json: { errors: result.errors.to_h }
    end
  end

  def webhook_params
    params.permit!.to_h
  end
end
