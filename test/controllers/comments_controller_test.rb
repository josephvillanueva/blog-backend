require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "lists a post's comments publicly" do
    get blog_comments_url(blogs(:alice_post)), as: :json

    assert_response :success
    assert_equal ["Great post!"], json.map { |comment| comment["body"] }
    assert_equal "bob", json.first["author"]["username"]
  end

  test "commenting requires a login" do
    post blog_comments_url(blogs(:alice_post)), params: { comment: { body: "Hi" } }, as: :json

    assert_response :unauthorized
  end

  test "adds a comment as the signed-in user" do
    assert_difference("Comment.count") do
      post blog_comments_url(blogs(:bob_post)), params: { comment: { body: "Thanks Bob" } },
                                                headers: auth_headers(users(:alice)), as: :json
    end

    assert_response :created
    assert_equal "alice", json["author"]["username"]
  end

  test "rejects an empty comment" do
    post blog_comments_url(blogs(:bob_post)), params: { comment: { body: "" } },
                                              headers: auth_headers(users(:alice)), as: :json

    assert_response :unprocessable_entity
  end

  test "only the comment's author can edit it" do
    patch comment_url(comments(:bob_on_alice)), params: { comment: { body: "Edited" } },
                                                headers: auth_headers(users(:alice)), as: :json

    assert_response :forbidden
  end

  test "the post's author can delete a comment on their post" do
    assert_difference("Comment.count", -1) do
      delete comment_url(comments(:bob_on_alice)), headers: auth_headers(users(:alice)), as: :json
    end

    assert_response :no_content
  end
end
