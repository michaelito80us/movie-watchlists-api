# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  respond_to :json


  private

  def respond_with(resource, _opts = {})
    render json: {
      satus: { code: 200, message: 'Logged in successfully.',
               data: {
                 user: UserSerializer.new(resource).serializable_hash[:data][:attributes],
                 watchlists: WatchlistIntroSerializer.new(resource.watchlists).serializable_hash[:data]
               } }
    }, status: :ok
  end

  def respond_to_on_destroy
    jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last,
                             Rails.application.credentials.devise_jwt_secret_key!).first
    current_user = User.find(jwt_payload['sub'])
    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end
