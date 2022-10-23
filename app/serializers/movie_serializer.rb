# app/serializers/movie_serializer.rb
class MovieSerializer
  include JSONAPI::Serializer
  attributes :name, :id, :duration, :overview, :score, :release_date, :poster_url, :tmdb_movie_id, :trailer_url,
             :popularity, :watch_provider
  # has_many :movie_casts
  # has_many :casts, through: :movie_casts

  attribute :release_year do |object|
    object.release_date.strftime('%Y')
  end

  attribute :duration_string do |object|
    "#{object.duration / 60}h #{object.duration % 60}m"
  end

  attribute :genres do |object|
    object.genres.map(&:name)
  end

  attribute :cast do |object|
    object.movie_casts.map do |movie_cast|
      {
        actor_name: movie_cast.cast.name,
        character: movie_cast.character,
        image_url: movie_cast.cast.image_url,
        job: movie_cast.job
      }
    end
  end

  attribute :recommended_movies do |object|
    object.recommendations.sample(5).map do |recommendation|
      movie = Movie.find(recommendation.recommended_movie_id)
      MovieIntroSerializer.new(movie).serializable_hash[:data][:attributes]
    end
  end

  # attribute :cast do |object|
  #   MovieCastSerializer.new(object.movie_casts).serializable_hash[:data]
  # end
end
