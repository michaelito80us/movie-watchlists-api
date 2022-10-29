# app/controllers/api/v1/users_controller
class Api::V1::UsersController < Api::V1::BaseController
  def update
    if current_user.update(user_params)
      render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
    else
      render_error(current_user)
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar)
  end
end
