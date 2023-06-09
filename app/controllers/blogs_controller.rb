class BlogsController < ApplicationController
  before_action :set_blog, only: %i[ show update destroy ]
  before_action :authorized, only: %i[ create update destroy]

  # GET /blogs
  def index
    @blogs = Blog.find_by_sql('SELECT blogs.*, users.username, users.email FROM blogs INNER JOIN users ON users.id = blogs.user_id')
  
    render json: @blogs
  end

  # def indexAll
  #   @blogs = Blog.all
  #   render json: @blogs
  # end

  # GET /blogs/1
  def show
    render json: @blog
  end

  # POST /blogs
  def create
    @blog = Blog.new(blog_params)
    @blog.user_id = @user.id
    @blog.username = @user.username


    if @blog.save
      render json: @blog, status: :created, location: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /blogs/1
  def update
    if @blog.update(blog_params)
      render json: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  # DELETE /blogs/1
  def destroy
    @blog.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      @blog = Blog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def blog_params
      params.require(:blog).permit(:title, :body, :user_id, :status,  :tag => [])
    end
end
