class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :login, :avatar_url, :url, :provider, :name
end
