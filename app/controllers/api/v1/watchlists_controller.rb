# app/controllers/api/v1/watchlists_controller.rb
class Api::V1::WatchlistsController < Api::V1::BaseController
  # def index
  #   watchlists = Watchlist.where(user: current_user)
  #   render json: watchlists
  # end

  def show
    @watchlist = Watchlist.find(params[:id])
    if @watchlist.user == current_user
      render json: WatchlistSerializer.new(@watchlist).serializable_hash[:data][:attributes]
    else
      rended json: { error: 'not your watchlist' }
    end
  end

  def create
    @watchlist = Watchlist.new(watchlist_params)
    @watchlist.user = current_user
    if @watchlist.save
      render json: WatchlistSerializer.new(@watchlist).serializable_hash[:data], status: :created
    else
      render_error(@watchlist)
    end
  end

  def destroy
    watchlist = Watchlist.find(params[:id])
    watchlist.destroy
    head :no_content
  end

  def update
    @watchlist = Watchlist.find(params[:id])

    unless params[:movie_id].nil?
      case params[:action]
      when 'add'
        movie = Movie.find(params[:movie_id])
        @watchlist.movies << movie
      when 'remove'
        movie = Movie.find(params[:movie_id])
        @watchlist.movies.delete(movie)
      when 'mark_watched'
        movie = Movie.find(params[:movie_id])
        WatchlistMovie.find_by(movie:, watchlist: @watchlist).update(watched: true)
      end
    end
    if @watchlist.update(watchlist_params)
      render json: WatchlistSerializer.new(@watchlist).serializable_hash[:data][:attributes]
    else
      render_error(@watchlist)
    end
  end

  private

  def watchlist_params
    params.permit(:name, :description, :movie_id, :action)
  end
end
