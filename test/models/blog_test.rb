require "test_helper"

class BlogTest < ActiveSupport::TestCase
  test "status must be draft or published" do
    blog = Blog.new(user: users(:alice), title: "T", body: "B", status: "archived")

    assert_not blog.valid?
  end

  test "status defaults to published" do
    assert_equal "published", Blog.new.status
  end
end
