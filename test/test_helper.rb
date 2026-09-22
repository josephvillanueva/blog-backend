ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
  fixtures :all
end

class ActionDispatch::IntegrationTest
  def auth_headers(user)
    { "Authorization" => "Bearer #{AuthToken.encode(user.id)}" }
  end

  def json
    JSON.parse(response.body)
  end
end
