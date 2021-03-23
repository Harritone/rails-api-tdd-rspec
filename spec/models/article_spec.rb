require 'rails_helper'

RSpec.describe Article, type: :model do
  describe "#validations" do

    let(:article) { build(:article) }
    
    it "tests that article is valid" do
      expect(article).to be_valid
    end
    
    it "has an invalid title" do
      article.title = ''
      expect(article).not_to be_valid
      expect(article.errors[:title]).to include("can't be blank")
    end
    
    it "has an invalid content" do
      article.content = ''
      expect(article).not_to be_valid
      expect(article.errors[:content]).to include("can't be blank")
    end
    
    it "has an invalid slug" do
      article.slug = ''
      expect(article).not_to be_valid
      expect(article.errors[:slug]).to include("can't be blank")
    end

    it "should validate uniqueness of the slug" do
      article1 = create(:article)
      another_article = build(:article)
      another_article.slug = article1.slug
      expect(another_article).not_to be_valid
      expect(another_article.errors[:slug]).to include("has already been taken")
      another_article.slug = 'unique-slug'
      expect(another_article).to be_valid
    end
    
  end
  
end
