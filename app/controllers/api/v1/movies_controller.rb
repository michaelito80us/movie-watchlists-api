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

    # render MovieSerializer.new(useful_data).serializable_hash[:data][:attributes]
    # render json: MovieSerializer.new(useful_data).serializable_hash
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
    # connect to the tmdb api
    # get the data
    id = params['tmdb_movie_id']
    movie = Movie.find_by tmdb_movie_id: id ||= api_call(id)
    if movie.nil?
      url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{API_KEY}&language=en-US"
      response = Faraday.get(url)
      # render the data
      useful_data = JSON.parse(response.body)
      debugger
      results = {
        tmdb_movie_id: useful_data['id'],
        name: useful_data['title'],
        overview: useful_data['overview'],
        release_date: useful_data['release_date'],
        poster_url: "https://image.tmdb.org/t/p/w185#{useful_data['poster_path']}",
        score: (useful_data['vote_average'] * 10).to_i,
        duration: useful_data['runtime'],
        duration_string: "#{useful_data['runtime'] / 60}h #{useful_data['runtime'] % 60}m",
        genres: useful_data['genres'].map { |genre| genre['name'] }
      }

      render json: results
    else
      render json: current_movie
    end
  end

  private

  def api_cal(id)
    url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{API_KEY}&language=en-US"
    response = Faraday.get(url)
    # render the data
    useful_data = JSON.parse(response.body)
  end
end

### for converting minutes into "xxxh xxxm"
# def time_conversion(minutes)
#     hours = minutes / 60
#     rest = minutes % 60
#     return "#{hours}h #{rest}m"
# end
