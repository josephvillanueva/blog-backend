class VotesController < ApplicationController
  before_action :set_blog

  # POST /blogs/:blog_id/vote  { "value": 1 } or { "value": -1 }
  # Casting again replaces the user's earlier vote on this post.
  def create
    vote = @blog.votes.find_or_initialize_by(user: current_user)
    vote.value = Integer(params[:value], exception: false)
    if vote.save
      render json: vote_payload(vote.value)
    else
      render_errors(vote)
    end
  end

  # DELETE /blogs/:blog_id/vote
  def destroy
    @blog.votes.where(user: current_user).destroy_all
    render json: vote_payload(0)
  end

  private

  def set_blog
    @blog = Blog.visible_to(current_user).find(params[:blog_id])
  end

  def vote_payload(value)
    { blog_id: @blog.id, value: value, score: @blog.votes.sum(:value) }
  end
end
