class MovieListSerializer
  include JSONAPI::Serializer
  attribute :movie do |object|
    id = (object.class.method_defined? :movie_id) ? object.movie_id : object.id
    movie = Movie.find(id)
    MovieIntroSerializer.new(movie).serializable_hash[:data][:attributes]
  end
end
