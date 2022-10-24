# app/controllers/api/v1/movies_controller.rb
class Api::V1::MoviesController < Api::V1::BaseController
  API_KEY = Rails.application.credentials.tmdb_api_key
  skip_before_action :authenticate_user!, only: %i[index show]

  include AddMovie

  def index
    puts "user signed in? #{user_signed_in?}"

    url = "https://api.themoviedb.org/3/discover/movie?api_key=#{API_KEY}&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate"
    response = Faraday.get(url)
    search_results = JSON.parse(response.body)['results']
    total_items = JSON.parse(response.body)['total_results']
    total_pages = JSON.parse(response.body)['total_pages']

    results = results_to_array(search_results)

    if user_signed_in?
      render json: { results: ResultsSerializer.new(results).serializable_hash[:data],
                     total_items:,
                     total_pages:,
                     user: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
                     watchlists: WatchlistIntroSerializer.new(current_user.watchlists).serializable_hash[:data] },
             status: :ok
    else
      render json: ResultsSerializer.new(results).serializable_hash[:data], status: :ok
    end
  end

  def show
    id = params['tmdb_movie_id']

    movie = Movie.find_by tmdb_movie_id: id
    movie = show_api_call(id) unless movie.complete_data

    # add to viewing history
    add_to_history(movie) if user_signed_in?

    render json: MovieSerializer.new(movie).serializable_hash[:data][:attributes]
  end

  def search
    query = search_strong_params[:query]
    page = search_strong_params[:page] || 1
    url = "https://api.themoviedb.org/3/search/movie?api_key=#{API_KEY}&language=en-US&query=#{query}&page=#{page}&include_adult=false"
    response = Faraday.get(url)
    search_results = JSON.parse(response.body)['results']
    total_items = JSON.parse(response.body)['total_results']
    total_pages = JSON.parse(response.body)['total_pages']

    results = results_to_array(search_results)

    render json: { results: ResultsSerializer.new(results).serializable_hash[:data],
                   total_items:,
                   total_pages: }, status: :ok
  end

  private

  def results_to_array(search_results)
    results = []
    search_results.each do |movie_data|
      movie = Movie.find_by tmdb_movie_id: movie_data['id']
      movie = new_movie(movie_data) if movie.nil?
      movie.save
      results << movie
    end
    results
  end

  def add_to_history(movie)
    # check if movie is already in history
    history = UserHistory.find_by user: current_user, movie: movie
    if history.nil?
      # add to history
      UserHistory.create!(user: current_user, movie:, visited_on: DateTime.now)
    else
      # update history
      history.update(visited_on: DateTime.now)
    end

    # keep history to 20 items
    total_history_items = UserHistory.where(user: current_user).all
    if total_history_items.count > 20
      # delete the oldest item
      oldest_item = total_items.max_by(&:visited_on)
      oldest_item.destroy
    end
  end

  def search_strong_params
    params.permit(:query, :page)
  end
end
