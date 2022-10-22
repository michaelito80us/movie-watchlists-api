# app/controllers/api/v1/watchlists_controller.rb
class Api::V1::WatchlistsController < Api::V1::BaseController
  # def index
  #   watchlists = Watchlist.where(user: current_user)
  #   render json: watchlists
  # end

  def show
    watchlist = Watchlist.find(params[:id])
    render json: watchlist
  end

  def create
    watchlist = Watchlist.new(watchlist_params)
    watchlist.user = current_user
    if watchlist.save
      render json: watchlist
    else
      render_error
    end
  end

  def destroy
    watchlist = Watchlist.find(params[:id])
    watchlist.destroy
    head :no_content
  end

  def update
    watchlist = Watchlist.find(params[:id])
    if watchlist.update(watchlist_params)
      render json: watchlist
    else
      render_error
    end
  end

  private

  def watchlist_params
    params.require(:watchlist).permit(:name, :description)
  end

  def watchilst_update_params
    params.require(:watchlist).permit(:movie_id)
  end
end
