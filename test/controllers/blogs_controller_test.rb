require "test_helper"

class BlogsControllerTest < ActionDispatch::IntegrationTest
  test "lists published posts publicly, without emails or drafts" do
    get blogs_url, as: :json

    assert_response :success
    titles = json.map { |blog| blog["title"] }
    assert_includes titles, "Alice's first post"
    assert_not_includes titles, "Alice's draft"
    assert_not_includes response.body, "@example.com"
  end

  test "includes score and comment count" do
    get blogs_url, as: :json

    post = json.find { |blog| blog["title"] == "Alice's first post" }
    assert_equal 1, post["score"]
    assert_equal 1, post["comments_count"]
    assert_equal "alice", post["author"]["username"]
  end

  test "shows the signed-in author their own drafts" do
    get blogs_url, headers: auth_headers(users(:alice)), as: :json

    assert_includes json.map { |blog| blog["title"] }, "Alice's draft"
  end

  test "hides a draft from other users" do
    get blog_url(blogs(:alice_draft)), headers: auth_headers(users(:bob)), as: :json

    assert_response :not_found
  end

  test "filters by tag" do
    get blogs_url, params: { tag: "Product" }

    assert_equal ["Bob's post"], json.map { |blog| blog["title"] }
  end

  test "creating a post requires a login" do
    post blogs_url, params: { blog: { title: "Hi", body: "There" } }, as: :json

    assert_response :unauthorized
  end

  test "creates a post for the signed-in user with normalized tags" do
    assert_difference("Blog.count") do
      post blogs_url, params: { blog: { title: "New", body: "Post", tags: [" Rails ", "rails", "API"] } },
                      headers: auth_headers(users(:bob)), as: :json
    end

    assert_response :created
    assert_equal "bob", json["author"]["username"]
    assert_equal %w[rails api], json["tags"]
  end

  test "rejects a post without a title" do
    post blogs_url, params: { blog: { title: "", body: "Body" } }, headers: auth_headers(users(:bob)), as: :json

    assert_response :unprocessable_entity
  end

  test "the author can update their post" do
    patch blog_url(blogs(:alice_post)), params: { blog: { title: "Updated" } },
                                        headers: auth_headers(users(:alice)), as: :json

    assert_response :success
    assert_equal "Updated", blogs(:alice_post).reload.title
  end

  test "another user cannot update the post" do
    patch blog_url(blogs(:alice_post)), params: { blog: { title: "Hijacked" } },
                                        headers: auth_headers(users(:bob)), as: :json

    assert_response :forbidden
    assert_equal "Alice's first post", blogs(:alice_post).reload.title
  end

  test "the author can delete their post" do
    assert_difference("Blog.count", -1) do
      delete blog_url(blogs(:alice_post)), headers: auth_headers(users(:alice)), as: :json
    end

    assert_response :no_content
  end

  test "another user cannot delete the post" do
    assert_no_difference("Blog.count") do
      delete blog_url(blogs(:alice_post)), headers: auth_headers(users(:bob)), as: :json
    end

    assert_response :forbidden
  end
end
