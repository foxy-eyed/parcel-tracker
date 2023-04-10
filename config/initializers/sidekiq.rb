# frozen_string_literal: true

redis = { url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379"), db: 0 }

Sidekiq.configure_client do |config|
  config.redis = redis
end

Sidekiq.configure_server do |config|
  config.redis = redis
end
