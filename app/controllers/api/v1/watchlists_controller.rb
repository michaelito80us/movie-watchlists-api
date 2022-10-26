# app/controllers/api/v1/watchlists_controller.rb
class Api::V1::WatchlistsController < Api::V1::BaseController
  before_action :set_watchlist, only: %i[show destroy update]
  # concern
  include AddMovie

  def index
    @watchlists = current_user.watchlists
    render json: WatchlistIntroSerializer.new(@watchlists).serializable_hash[:data]
  end

  def show
    if @watchlist.nil?
      rended json: { error: 'not your watchlist' }
    else
      render json: WatchlistSerializer.new(@watchlist).serializable_hash[:data][:attributes]
    end
  end

  def create
    @watchlist = Watchlist.new(watchlist_params(:name, :description))
    @watchlist.user = current_user
    if @watchlist.save
      render json: WatchlistSerializer.new(@watchlist).serializable_hash[:data][:attributes], status: :created
    else
      render_error(@watchlist)
    end
  end

  def destroy
    if @watchlist.destroy
      render json: { message: 'watchlist deleted' }, status: :ok
    else
      render_error(@watchlist)
    end
  end

  def update
    if @watchlist.update(watchlist_params(:name, :description))

      if watchlist_params(:movie_id).nil?
        render json: WatchlistSerializer.new(@watchlist).serializable_hash[:data][:attributes]
      else
        @movie = Movie.find(watchlist_params(:movie_id)['movie_id'])
        @watchlist_movie = WatchlistMovie.find_by watchlist: @watchlist, movie: @movie
        case watchlist_params(:movie_action)['movie_action']
        when 'add'
          tmdb_movie_id = @movie.tmdb_movie_id
          @movie = show_api_call(tmdb_movie_id)
          # GetMovieDetailsJob.perform_later(@movie) unless @movie.complete_data
          add_to_watchlist(@watchlist, @movie, @watchlist_movie)
        when 'remove'
          remove_from_watchlist(@watchlist, @movie, @watchlist_movie)
        when 'toggle_watched'
          toggle_watched(@watchlist, @movie, @watchlist_movie)
        else
          render json: { error: 'invalid action' }, status: :unprocessable_entity
        end
      end
    else
      render_error(@watchlist)
    end
  end

  private

  def set_watchlist
    @watchlist = Watchlist.find_by id: params[:id], user: current_user
  end

  def add_to_watchlist(watchlist, movie, watchlist_movie)
    render json: { error: 'movie already in watchlist' } and return unless watchlist_movie.nil?

    watchlist_movie = WatchlistMovie.create!(movie:, watchlist:)
    watchlist.watchlist_movies << watchlist_movie
    save_watchlist(watchlist)
  end

  def remove_from_watchlist(watchlist, _movie, watchlist_movie)
    render json: { error: 'movie not in watchlist' } and return if watchlist_movie.nil?

    watchlist.watchlist_movies.delete(watchlist_movie)
    save_watchlist(watchlist)
  end

  def toggle_watched(watchlist, _movie, watchlist_movie)
    render json: { error: 'movie not in watchlist' } and return if watchlist_movie.nil?

    watchlist_movie.watched = watchlist_movie.watched ? false : true
    watchlist_movie.save
    save_watchlist(watchlist)
  end

  def save_watchlist(watchlist)
    watchlist.total_items = watchlist.movies.count
    watchlist.unwatched_runtime = watchlist.movies.where(watchlist_movies: { watched: false }).sum(:duration)
    watchlist.score_sum = watchlist.movies.sum(:score)
    if watchlist.save
      render json: WatchlistSerializer.new(watchlist).serializable_hash[:data][:attributes]
    else
      render_error(watchlist)
    end
  end

  def calculate_unwatched_runtime(watchlist)
    watchlist.unwatched_runtime = watchlist.movies.where(watchlist_movies: { watched: false }).sum(:duration)
  end

  def watchlist_params(*args)
    params.require(:watchlist).permit(*args)
    # params.require(:watchlist).permit(:name, :description)
  end
end
