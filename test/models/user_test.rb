require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "as_json leaves out the password digest and email by default" do
    json = users(:alice).as_json

    assert_equal %w[created_at id username], json.keys.sort
  end

  test "email must look like an email" do
    user = User.new(username: "eve", email: "not-an-email", password: "password123")

    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end
end
