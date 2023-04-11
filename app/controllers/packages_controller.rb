# frozen_string_literal: true

class PackagesController < ApplicationController
  def index
    packages = Package.all.order(created_at: :desc)
    render json: packages, only: %i[id track]
  end

  def show
    package = Package.find(params[:id])
    render json: package
  end

  def create
    result = PackageContract.new.call(**package_params)
    if result.success?
      package = Package.find_by(track: result[:track])
      unless package
        Package.transaction do
          package = Package.create!(track: result[:track])
          PackageRepository.new.with_package(package.id) do |package_agg|
            package_agg.initiate_tracking(track: result[:track])
          end
        end
      end
      render json: package
    else
      render status: :unprocessable_entity, json: { errors: result.errors }
    end
  end

  private

  def package_params
    params.require(:package).permit(:track)
  end
end
