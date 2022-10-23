class WatchlistSerializer
  include JSONAPI::Serializer
  attributes :name, :id, :description, :unwatched_runtime, :total_items, :score_sum
  # has_many :watchlist_movies
  # belongs_to :user

  attribute :movies do |object|
    object.watchlist_movies.map do |watchlist_movie|
      WatchlistMovieSerializer.new(watchlist_movie).serializable_hash[:data]
    end
  end
end
