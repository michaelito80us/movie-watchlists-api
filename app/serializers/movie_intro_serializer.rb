class MovieIntroSerializer
  include JSONAPI::Serializer
  attributes :id, :tmdb_movie_id, :poster_url, :name, :score

  attribute :release_year do |object|
    object.release_date.strftime('%Y')
  end
end
