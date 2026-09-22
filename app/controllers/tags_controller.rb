class TagsController < ApplicationController
  skip_before_action :authorize!

  # GET /tags
  # Tags used on published posts, most used first.
  def index
    counts = Blog.published.pluck(:tags).flatten.tally
    render json: counts.sort_by { |tag, count| [-count, tag] }.map { |tag, count| { tag: tag, count: count } }
  end
end
