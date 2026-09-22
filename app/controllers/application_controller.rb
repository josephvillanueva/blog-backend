class ApplicationController < ActionController::API
  before_action :authorize!

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |error|
    render json: { error: error.message }, status: :bad_request
  end

  private

  # The signed-in user, or nil. Safe to call on public endpoints.
  def current_user
    return @current_user if defined?(@current_user)

    payload = AuthToken.decode(bearer_token)
    @current_user = payload && User.find_by(id: payload["user_id"])
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    header.delete_prefix("Bearer ").strip if header.start_with?("Bearer ")
  end

  def authorize!
    render json: { error: "Please log in" }, status: :unauthorized unless current_user
  end

  def forbid(message)
    render json: { error: message }, status: :forbidden
  end

  def render_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
