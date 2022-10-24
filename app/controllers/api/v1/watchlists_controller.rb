# app/controllers/api/v1/watchlists_controller.rb
class Api::V1::WatchlistsController < Api::V1::BaseController
  # concern
  include AddMovie

  def index
    @watchlists = current_user.watchlists
    render json: WatchlistIntroSerializer.new(@watchlists).serializable_hash[:data]
  end

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
      render json: WatchlistSerializer.new(@watchlist).serializable_hash[:data][:attributes], status: :created
    else
      render_error(@watchlist)
    end
  end

  def destroy
    @watchlist = Watchlist.find(params[:id])
    @watchlist.destroy
    head :no_content
  end

  def update
    @watchlist = Watchlist.find(params[:id])

    if @watchlist.update(watchlist_params)

      if params[:movie_id].nil?
        render json: WatchlistSerializer.new(@watchlist).serializable_hash[:data][:attributes]
      else
        @movie = Movie.find(params[:movie_id])
        @watchlist_movie = WatchlistMovie.find_by watchlist: @watchlist, movie: @movie
        case params[:movie_action]
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
      # save_watchlist(@watchlist)
    else
      render_error(@watchlist)
    end
  end

  private

  def add_to_watchlist(watchlist, movie, watchlist_movie)
    render json: { error: 'movie already in watchlist' } and return unless watchlist_movie.nil?

    watchlist_movie = WatchlistMovie.create!(movie:, watchlist:)
    watchlist.watchlist_movies << watchlist_movie
    watchlist.total_items += 1
    watchlist.unwatched_runtime += movie.duration
    watchlist.score_sum += movie.score
    save_watchlist(watchlist)
  end

  def remove_from_watchlist(watchlist, movie, watchlist_movie)
    render json: { error: 'movie not in watchlist' } and return if watchlist_movie.nil?

    watchlist.watchlist_movies.delete(watchlist_movie)
    watchlist.total_items -= 1
    watchlist.unwatched_runtime -= movie.duration
    watchlist.score_sum -= movie.score
    save_watchlist(watchlist)
  end

  def toggle_watched(watchlist, movie, watchlist_movie)
    render json: { error: 'movie not in watchlist' } and return if watchlist_movie.nil?

    if watchlist_movie.watched
      watchlist_movie.watched = false
      watchlist.unwatched_runtime += movie.duration
    else
      watchlist_movie.watched = true
      watchlist.unwatched_runtime -= movie.duration
    end
    watchlist_movie.save
    save_watchlist(watchlist)
  end

  def save_watchlist(watchlist)
    if watchlist.save
      render json: WatchlistSerializer.new(watchlist).serializable_hash[:data][:attributes]
    else
      render_error(watchlist)
    end
  end

  def watchlist_params
    params.permit(:name, :description)
  end
end
