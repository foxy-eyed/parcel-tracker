# frozen_string_literal: true

require "sidekiq/web"

# Configure Sidekiq-specific session middleware
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use Rails.application.config.session_store, Rails.application.config.session_options

Rails.application.routes.draw do
  mount RailsEventStore::Browser => "/res" if Rails.env.development?
  mount Sidekiq::Web, at: "/sidekiq"

  resources :packages, only: %i[index show create] do
    resources :notifications, only: %i[index create], controller: :subscriptions, shallow: true
  end

  post "webhook/:provider/arrived/:track", to: "webhooks#arrived"
  post "webhook/:provider/departed/:track", to: "webhooks#dispatched"
  post "webhook/:provider/deliver-attempt/:track", to: "webhooks#delivery_attempted"
end
