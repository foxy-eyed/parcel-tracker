# frozen_string_literal: true

class ApplicationController < ActionController::API
  def current_user
    @current_user ||= User.find_by(id: request.headers["X-User-ID"])
  end

  def event_store
    Rails.configuration.event_store
  end
end
