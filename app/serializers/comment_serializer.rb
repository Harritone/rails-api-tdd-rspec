class CommentSerializer
  include JSONAPI::Serializer
  attributes :content
  belongs_to :user
  belongs_to :article
end
