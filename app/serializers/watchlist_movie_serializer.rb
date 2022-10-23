class WatchlistMovieSerializer
  include JSONAPI::Serializer
  attributes :movie_id, :watchlist_id, :watched, :score
  belongs_to :movie
  belongs_to :watchlist
end
