class GenreSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :tmdb_genre_id
end
