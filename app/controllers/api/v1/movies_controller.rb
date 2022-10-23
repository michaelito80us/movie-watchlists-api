# app/controllers/api/v1/movies_controller.rb
class Api::V1::MoviesController < Api::V1::BaseController
  API_KEY = Rails.application.credentials.tmdb_api_key
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    puts "user signed in? #{user_signed_in?}"
    # for the images:
    # "images": {
    #         "base_url": "http://image.tmdb.org/t/p/",
    #         "secure_base_url": "https://image.tmdb.org/t/p/",
    #         "backdrop_sizes": [
    #             "w300",
    #             "w780",
    #             "w1280",
    #             "original"
    #         ],
    #         "logo_sizes": [
    #             "w45",
    #             "w92",
    #             "w154",
    #             "w185",
    #             "w300",
    #             "w500",
    #             "original"
    #         ],
    #         "poster_sizes": [
    #             "w92",
    #             "w154",
    #             "w185",
    #             "w342",
    #             "w500",
    #             "w780",
    #             "original"
    #         ],
    #         "profile_sizes": [
    #             "w45",
    #             "w185",
    #             "h632",
    #             "original"
    #         ],
    #         "still_sizes": [
    #             "w92",
    #             "w185",
    #             "w300",
    #             "original"
    #         ]
    # connect to the tmdb api
    # get the data
    url = "https://api.themoviedb.org/3/discover/movie?api_key=#{API_KEY}&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate"
    response = Faraday.get(url)
    # render the data
    search_results = JSON.parse(response.body)['results']

    results = []
    search_results.each do |movie_data|
      movie = Movie.find_by tmdb_movie_id: movie_data['id']
      movie = new_movie(movie_data) if movie.nil?
      movie.save
      results << movie
      # item = {}
      # item[:tmbd_movie_id] = movie_data['id']
      # item[:name] = movie_data['title']
      # item[:overview] = movie_data['overview']
      # item[:release_year] = movie_data['release_date'][0...4]
      # item[:poster_url] = "https://image.tmdb.org/t/p/w185#{movie_data['poster_path']}"
      # item[:score] = (movie_data['vote_average'] * 10).to_i
      # results << item
    end
    if user_signed_in?
      render json: { results: ResultsSerializer.new(results).serializable_hash[:data], user: current_user, watchlists: WatchlistSerializer.new(current_user.watchlists).serializable_hash[:data] },
             status: :ok
    else
      render json: ResultsSerializer.new(results).serializable_hash[:data], status: :ok
    end
  end

  def show
    id = params['tmdb_movie_id']

    movie = Movie.find_by tmdb_movie_id: id
    movie = show_api_call(id) if movie.nil?

    # add to viewing history
    add_to_history(movie) if user_signed_in?

    render json: MovieSerializer.new(movie).serializable_hash[:data][:attributes]
  end

  private

  def add_to_history(movie)
    # check if movie is already in history
    history = UserHistory.find_by user: current_user, movie: movie
    debugger
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

  def new_movie(data)
    new_movie = Movie.new
    new_movie.name = data['title']
    new_movie.score = (data['vote_average'] * 10).to_i
    new_movie.overview = data['overview']
    new_movie.release_date = Date.parse(data['release_date'])
    new_movie.poster_url = "https://image.tmdb.org/t/p/w185#{data['poster_path']}"
    new_movie.tmdb_movie_id = data['id']
    new_movie.popularity = data['popularity']
    new_movie
  end

  def add_genres(genre_ids, movie)
    genre_ids.each do |genre|
      movie_genre = Genre.find_by name: genre['name']
      movie_genre = Genre.create(name: genre['name'], tmdb_genre_id: genre['id']) if movie_genre.nil?
      movie.genres << movie_genre
    end
  end

  def add_cast(movie_data, movie)
    movie_data['cast'].each do |cast|
      next unless cast['known_for_department'] == 'Acting' && !cast['profile_path'].nil?

      movie_cast = MovieCast.new
      movie_cast.movie = movie
      movie_cast.character = cast['character']
      movie_cast.job = 'Actor'
      movie_cast.cast = Cast.find_by tmdb_cast_id: cast['id']
      if movie_cast.cast.nil?
        movie_cast.cast = Cast.create(name: cast['name'], tmdb_cast_id: cast['id'],
                                      image_url: "https://image.tmdb.org/t/p/w185#{cast['profile_path']}")
      end
      movie_cast.save
      break if movie.casts.count == 9
    end

    movie_data['crew'].each do |crew|
      next unless crew['job'] == 'Director' && !crew['profile_path'].nil?

      movie_cast = MovieCast.new
      movie_cast.movie = movie
      movie_cast.character = crew['job']
      movie_cast.job = 'Director'
      movie_cast.cast = Cast.find_by tmdb_cast_id: crew['id']
      if movie_cast.cast.nil?
        movie_cast.cast = Cast.create(name: crew['name'], tmdb_cast_id: crew['id'],
                                      image_url: "https://image.tmdb.org/t/p/w185#{crew['profile_path']}")
      end
      movie_cast.save
    end
  end

  def add_trailer(videos, movie)
    key = videos.find { |video| video['type'] == 'Trailer' && video['site'] == 'YouTube' }['key']
    movie.trailer_url = "https://www.youtube.com/watch?v=#{key}"
    movie.save
  end

  def add_recommendations(recommended_movies, movie)
    recommended_movies.each do |_recommended_movie|
      recommended_movie = Movie.find_by tmdb_movie_id: movie['id']
      recommended_movie = new_movie(movie) if movie.nil?
    end
  end

  def show_api_call(id)
    puts '***** I MADE AN API CALL *****'
    url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{API_KEY}&language=en-US&append_to_response=credits,recommendations,videos"
    response = Faraday.get(url)
    # render the data
    movie_data = JSON.parse(response.body)

    movie = new_movie(movie_data)
    movie.duration = (movie_data['runtime']).to_i
    movie.complete_data = true
    movie.save
    add_genres(movie_data['genres'], movie)
    add_cast(movie_data['credits'], movie)
    add_trailer(movie_data['videos']['results'], movie)
    # add_recommendations(movie_data['recommendations']['results'], movie)
    movie
  end
end
