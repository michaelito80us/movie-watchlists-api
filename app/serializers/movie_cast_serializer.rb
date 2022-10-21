class MovieCastSerializer
  include JSONAPI::Serializer
  belongs_to :movie
  belongs_to :cast
  attributes :character
  # attribute :actor_name do |object|
  #   object.cast.name(&:name)
  # end
  # attribute :image_url do |object|
  #   object.cast.image_url(&:image_url)
  # end

  # attribute :details do |object|
  #   CastSerializer.new(object.cast).serializable_hash[:data]
  # end
end
