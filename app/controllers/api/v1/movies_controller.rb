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
    useful_data = JSON.parse(response.body)['results']

    results = []
    useful_data.each do |movie_data|
      item = {}
      item[:tmbd_movie_id] = movie_data['id']
      item[:name] = movie_data['title']
      item[:overview] = movie_data['overview']
      item[:release_year] = movie_data['release_date'][0...4]
      item[:poster_url] = "https://image.tmdb.org/t/p/w185#{movie_data['poster_path']}"
      item[:score] = (movie_data['vote_average'] * 10).to_i
      results << item
    end

    if user_signed_in?
      render json: { results:, movie: MovieSerializer.new(Movie.first).serializable_hash[:data][:attributes] },
             status: :ok
    else
      render json: results, status: :ok
    end
  end

  def show
    id = params['tmdb_movie_id']

    movie = Movie.find_by tmdb_movie_id: id
    movie = show_api_call(id) if movie.nil?

    render json: MovieSerializer.new(movie).serializable_hash[:data][:attributes]
  end

  private

  def new_movie(data)
    new_movie = Movie.new
    new_movie.name = data['title']
    new_movie.score = (data['vote_average'] * 10).to_i
    new_movie.overview = data['overview']
    new_movie.release_date = Date.parse(data['release_date'])
    new_movie.poster_url = "https://image.tmdb.org/t/p/w185#{data['poster_path']}"
    new_movie.tmdb_movie_id = data['id']
    new_movie
  end

  def add_genres(movie_data, movie)
    movie_data['genres'].each do |genre|
      movie_genre = MovieGenre.new
      movie_genre.movie = movie
      movie_genre.genre = Genre.find_by name: genre['name']
      movie_genre.genre = Genre.create(name: genre['name'], tmdb_genre_id: genre['id']) if movie_genre.genre.nil?
      movie_genre.save
    end
  end

  def add_cast(movie_data, movie)
    movie_data['credits']['cast'].each do |cast|
      next unless cast['known_for_department'] == 'Acting' && !cast['profile_path'].nil?

      movie_cast = MovieCast.new
      movie_cast.movie = movie
      movie_cast.character = cast['character']
      movie_cast.cast = Cast.find_by tmdb_cast_id: cast['id']
      if movie_cast.cast.nil?
        movie_cast.cast = Cast.create(name: cast['name'], tmdb_cast_id: cast['id'],
                                      image_url: "https://image.tmdb.org/t/p/w185#{cast['profile_path']}")
      end
      movie_cast.save
      break if movie.casts.count == 10
    end
  end

  def show_api_call(id)
    puts '***** I MADE AN API CALL *****'
    url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{API_KEY}&language=en-US&append_to_response=credits,recommendations"
    response = Faraday.get(url)
    # render the data
    movie_data = JSON.parse(response.body)

    movie = new_movie(movie_data)
    movie.duration = (movie_data['runtime']).to_i
    movie.save
    add_genres(movie_data, movie)
    add_cast(movie_data, movie)
    movie
  end
end
