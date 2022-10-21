class CastSerializer
  include JSONAPI::Serializer

  attributes :image_url, :tmdb_cast_id, :name
  # attribute :actor_name do |object|
  #   object.name(&:name)
  # end
end
