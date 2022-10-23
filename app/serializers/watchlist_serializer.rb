class WatchlistSerializer
  include JSONAPI::Serializer
  attributes :name, :id, :description, :unwatched_runtime, :total_items, :score_sum
  # has_many :watchlist_movies
  # belongs_to :user

  # attribute :movies do |object|
  #   object.watchlist_movies.map do |watchlist_movie|
  #     WatchlistMovieSerializer.new(watchlist_movie).serializable_hash[:data]
  #   end
  # end

  attribute :movie_list do |object|
    object.watchlist_movies.map do |watchlist_movie|
      WatchlistMovieSerializer.new(watchlist_movie).serializable_hash[:data][:attributes]
    end
    # object.movies.map do |watchlist_movie|
    #   MovieIntroSerializer.new(watchlist_movie).serializable_hash[:data][:attributes]
    # end
  end

  attribute :average_score do |object|
    object.total_items.positive? ? object.score_sum / object.total_items : 0
  end

  attribute :unwatched_string do |object|
    hours = object.unwatched_runtime / 60
    minutes = object.unwatched_runtime % 60
    "#{hours}h #{minutes}m"
  end
end
