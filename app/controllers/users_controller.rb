class UsersController < ApplicationController
  skip_before_action :authorize!, only: %i[create login]

  # POST /users
  def create
    user = User.new(user_params)
    if user.save
      render json: session_payload(user), status: :created
    else
      render_errors(user)
    end
  end

  # POST /login
  def login
    user = User.find_by("LOWER(username) = ?", params[:username].to_s.downcase)
    if user&.authenticate(params[:password].to_s)
      render json: session_payload(user)
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  # GET /auto_login
  def auto_login
    render json: current_user.as_json(only: User::PRIVATE_FIELDS)
  end

  private

  def user_params
    params.permit(:username, :password, :email)
  end

  def session_payload(user)
    { user: user.as_json(only: User::PRIVATE_FIELDS), token: AuthToken.encode(user.id) }
  end
end
