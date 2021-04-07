require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe "#validation" do
    it "should have valid factory" do
      user = create :user
      access_token = build :access_token, user_id: user.id
      expect(access_token).to be_valid
    end

    it "should validate presence of token" do 
      user = create :user
      access_token = build :access_token, user_id: user.id
      access_token.token = nil
      expect(access_token).not_to be_valid
      access_token.token = 'token'
      expect(access_token).to be_valid
    end
  end
  
end
