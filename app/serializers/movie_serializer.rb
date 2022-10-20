class MovieSerializer
  include JSONAPI::Serializer
  attributes :name, :id, :duration, :overview, :score, :release_date, :poster_url, :tmbd_movie_id
end
