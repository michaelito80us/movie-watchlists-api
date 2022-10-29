class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :name, :created_at

  attribute :avatar_url, &:avatar_thumbnail
end
