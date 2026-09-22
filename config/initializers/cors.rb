# Browsers may call the API from the origins listed in CORS_ORIGINS
# (comma-separated). Defaults to any origin for local development.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch("CORS_ORIGINS", "*").split(",").map(&:strip))

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head]
  end
end
