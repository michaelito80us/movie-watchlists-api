# app/serializers/movie_serializer.rb
class MovieSerializer
  include JSONAPI::Serializer
  attributes :name, :id, :duration, :overview, :score, :release_date, :poster_url, :tmdb_movie_id

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
        name: movie_cast.cast.name,
        character: movie_cast.character,
        image_url: movie_cast.cast.image_url
      }
    end
  end
end
