require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  test "voting again replaces the earlier vote" do
    assert_no_difference("Vote.count") do
      post blog_vote_url(blogs(:alice_post)), params: { value: -1 }, headers: auth_headers(users(:bob)), as: :json
    end

    assert_response :success
    assert_equal(-1, json["score"])
  end

  test "a new voter adds to the score" do
    post blog_vote_url(blogs(:alice_post)), params: { value: 1 }, headers: auth_headers(users(:alice)), as: :json

    assert_equal 2, json["score"]
  end

  test "rejects a value other than 1 or -1" do
    post blog_vote_url(blogs(:alice_post)), params: { value: 5 }, headers: auth_headers(users(:alice)), as: :json

    assert_response :unprocessable_entity
  end

  test "removes a vote" do
    delete blog_vote_url(blogs(:alice_post)), headers: auth_headers(users(:bob)), as: :json

    assert_response :success
    assert_equal 0, json["score"]
  end

  test "voting requires a login" do
    post blog_vote_url(blogs(:alice_post)), params: { value: 1 }, as: :json

    assert_response :unauthorized
  end
end
