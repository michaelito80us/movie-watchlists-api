# app/controllers/api/v1/movies_controller.rb
class Api::V1::MoviesController < Api::V1::BaseController
  API_KEY = Rails.application.credentials.tmdb_api_key
  def index
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
    useful_data.each do |movie|
      item = {}
      item[:tmbd_movie_id] = movie['id']
      item[:name] = movie['title']
      item[:overview] = movie['overview']
      item[:release_year] = movie['release_date'][0...4]
      item[:poster_url] = "https://image.tmdb.org/t/p/w185#{movie['poster_path']}"
      item[:score] = (movie['vote_average'] * 10).to_i
      results << item
    end

    render json: results
  end

  def show
    id = params['tmdb_movie_id']

    movie = Movie.find_by tmdb_movie_id: id
    movie = show_api_call(id) if movie.nil?

    render json: MovieSerializer.new(movie)
  end

  private

  def show_api_call(id)
    puts '***** I MADE AN API CALL *****'
    url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{API_KEY}&language=en-US&append_to_response=credits"
    response = Faraday.get(url)
    # render the data
    useful_data = JSON.parse(response.body)

    movie = Movie.new
    movie.name = useful_data['title']
    movie.duration = (useful_data['runtime']).to_i
    movie.score = (useful_data['vote_average'] * 10).to_i
    movie.overview = useful_data['overview']
    movie.release_date = Date.parse(useful_data['release_date'])
    movie.poster_url = "https://image.tmdb.org/t/p/w185#{useful_data['poster_path']}"
    movie.tmdb_movie_id = useful_data['id']
    movie.save
    useful_data['genres'].each do |genre|
      movie_genre = MovieGenre.new
      movie_genre.movie = movie
      movie_genre.genre = Genre.find_by name: genre['name']
      movie_genre.genre = Genre.create(name: genre['name'], tmdb_genre_id: genre['id']) if movie_genre.genre.nil?
      movie_genre.save
    end
    useful_data['credits']['cast'].first(10).each do |cast|
      movie_cast = MovieCast.new
      movie_cast.movie = movie
      movie_cast.character = cast['character']
      movie_cast.cast = Cast.find_by tmdb_cast_id: cast['id']
      if movie_cast.cast.nil?
        movie_cast.cast = Cast.create(name: cast['name'], tmdb_cast_id: cast['id'],
                                      image_url: "https://image.tmdb.org/t/p/w185#{cast['profile_path']}")
      end
      movie_cast.save
    end
    movie
  end
end
