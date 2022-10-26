# app/controllers/api/v1/histories_controller.rb
class Api::V1::HistoriesController < Api::V1::BaseController
  def index
    if user_signed_in?
      @history = UserHistory.where(user: current_user).sort_by(&:visited_on).reverse
      render json: HistorySerializer.new(@history).serializable_hash[:data]
    else
      render json: { error: 'You must be signed in to view your history' }, status: :unauthorized
    end
  end
end
