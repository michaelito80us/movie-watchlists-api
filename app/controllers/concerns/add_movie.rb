module AddMovie
  extend ActiveSupport::Concern
  API_KEY = Rails.application.credentials.tmdb_api_key

  def show_api_call(id)
    puts '***** I MADE AN API CALL *****'
    url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{API_KEY}&language=en-US&append_to_response=credits,recommendations,videos,watch%2Fproviders"
    response = Faraday.get(url)
    # render the data
    movie_data = JSON.parse(response.body)
    render json: { error: 'Movie not found' }, status: :not_found and return if movie_data['status_code'] == 34

    movie = Movie.find_by tmdb_movie_id: id
    movie = new_movie(movie_data) if movie.nil?
    movie.duration = (movie_data['runtime']).to_i
    unless (movie_data['watch/providers'] && movie_data['watch/providers']['results']['US'] && movie_data['watch/providers']['results']['US']['flatrate']).nil?
      movie.watch_provider = movie_data['watch/providers']['results']['US']['flatrate'][0]['provider_name']
    end
    movie.save
    add_genres(movie_data['genres'], movie)
    add_cast(movie_data['credits'], movie)
    add_trailer(movie_data['videos']['results'], movie)
    add_recommendations(movie_data['recommendations']['results'], movie)
    movie.update(complete_data: true)
    movie
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
    recommended_movies.each do |recommendation|
      recommended_movie = Movie.find_by tmdb_movie_id: recommendation['id']
      recommended_movie = new_movie(recommendation) if recommended_movie.nil?
      recommended_movie.save
      movie.recommended_movies << recommended_movie
    end
  end
end
