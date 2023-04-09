# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsEventStore::Browser => "/res" if Rails.env.development?

  resources :packages, only: %i[index show create] do
    resources :notifications, only: %i[index create], controller: :subscriptions, shallow: true
  end

  post "webhooks/:provider/arrived/:track", to: "webhooks#arrived"
  post "webhooks/:provider/departed/:track", to: "webhooks#dispatched"
  post "webhooks/:provider/deliver-attempt/:track", to: "webhooks#delivery_attempted"
end
