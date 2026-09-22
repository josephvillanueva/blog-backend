require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "registers a user and returns a token without the password digest" do
    assert_difference("User.count") do
      post "/users", params: { username: "carol", email: "carol@example.com", password: "password123" }, as: :json
    end

    assert_response :created
    assert json["token"].present?
    assert_equal "carol", json["user"]["username"]
    assert_nil json["user"]["password_digest"]
  end

  test "rejects a duplicate username" do
    post "/users", params: { username: "ALICE", email: "new@example.com", password: "password123" }, as: :json

    assert_response :unprocessable_entity
    assert_includes json["errors"], "Username has already been taken"
  end

  test "rejects a short password" do
    post "/users", params: { username: "dave", email: "dave@example.com", password: "short" }, as: :json

    assert_response :unprocessable_entity
  end

  test "logs in with the right password" do
    post "/login", params: { username: "alice", password: "password123" }, as: :json

    assert_response :success
    assert_equal users(:alice).id, AuthToken.decode(json["token"])["user_id"]
  end

  test "refuses a wrong password with 401" do
    post "/login", params: { username: "alice", password: "wrong-password" }, as: :json

    assert_response :unauthorized
  end

  test "auto_login returns the signed-in user" do
    get "/auto_login", headers: auth_headers(users(:alice)), as: :json

    assert_response :success
    assert_equal "alice@example.com", json["email"]
  end

  test "auto_login requires a token" do
    get "/auto_login", as: :json

    assert_response :unauthorized
  end

  test "an expired token is rejected" do
    token = AuthToken.encode(users(:alice).id, expires_at: 1.minute.ago)
    get "/auto_login", headers: { "Authorization" => "Bearer #{token}" }, as: :json

    assert_response :unauthorized
  end
end
