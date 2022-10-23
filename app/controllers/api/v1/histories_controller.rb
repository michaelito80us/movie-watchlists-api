# app/controllers/api/v1/histories_controller.rb
class Api::V1::HistoriesController < Api::V1::BaseController
  def index
    @history = UserHistory.where(user: current_user).sort_by(&:visited_on).reverse
    render json: HistorySerializer.new(@history).serializable_hash[:data]
  end
end
