class CommentsController < ApplicationController
  skip_before_action :authorize!, only: :index
  before_action :set_blog, only: %i[index create]
  before_action :set_comment, only: %i[update destroy]

  # GET /blogs/:blog_id/comments
  def index
    render json: @blog.comments.includes(:user).order(:created_at)
  end

  # POST /blogs/:blog_id/comments
  def create
    comment = @blog.comments.new(comment_params.merge(user: current_user))
    if comment.save
      render json: comment, status: :created
    else
      render_errors(comment)
    end
  end

  # PATCH /comments/:id
  def update
    return forbid("You can only edit your own comments") unless @comment.user_id == current_user.id

    if @comment.update(comment_params)
      render json: @comment
    else
      render_errors(@comment)
    end
  end

  # DELETE /comments/:id
  # The comment's author or the post's author can remove it.
  def destroy
    unless [@comment.user_id, @comment.blog.user_id].include?(current_user.id)
      return forbid("You can only delete your own comments or comments on your posts")
    end

    @comment.destroy
    head :no_content
  end

  private

  def set_blog
    @blog = Blog.visible_to(current_user).find(params[:blog_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
