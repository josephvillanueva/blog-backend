class BlogsController < ApplicationController
  skip_before_action :authorize!, only: %i[index show]
  before_action :set_blog, only: %i[show update destroy]
  before_action :require_author!, only: %i[update destroy]

  # GET /blogs?tag=rails
  # Published posts, plus the signed-in user's own drafts.
  def index
    blogs = Blog.visible_to(current_user).with_stats.includes(:user).order(created_at: :desc)
    blogs = blogs.tagged(params[:tag]) if params[:tag].present?
    render json: blogs
  end

  # GET /blogs/:id
  def show
    render json: @blog
  end

  # POST /blogs
  def create
    blog = current_user.blogs.new(blog_params)
    if blog.save
      render json: blog, status: :created, location: blog
    else
      render_errors(blog)
    end
  end

  # PATCH /blogs/:id
  def update
    if @blog.update(blog_params)
      render json: @blog
    else
      render_errors(@blog)
    end
  end

  # DELETE /blogs/:id
  def destroy
    @blog.destroy
    head :no_content
  end

  private

  def set_blog
    @blog = Blog.visible_to(current_user).with_stats.find(params[:id])
  end

  def require_author!
    forbid("You can only change your own posts") unless @blog.user_id == current_user.id
  end

  def blog_params
    params.require(:blog).permit(:title, :body, :status, tags: [])
  end
end
