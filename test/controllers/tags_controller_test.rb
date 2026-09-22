require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  test "counts tags on published posts only, most used first" do
    get tags_url, as: :json

    assert_response :success
    assert_equal [{ "tag" => "api", "count" => 1 }, { "tag" => "product", "count" => 1 }, { "tag" => "rails", "count" => 1 }],
                 json
  end
end
