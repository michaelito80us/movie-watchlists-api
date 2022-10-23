class WatchlistMovieSerializer
  include JSONAPI::Serializer
  attributes :watched

  attribute :movie do |object|
    MovieIntroSerializer.new(object.movie).serializable_hash[:data][:attributes]
  end
end
