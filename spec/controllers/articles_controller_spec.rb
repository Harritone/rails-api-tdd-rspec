require 'rails_helper'

RSpec.describe ArticlesController do
  subject { get :index } 
  describe "#index" do
    it "should return a succes respond" do
      subject 
      # expect(response).to have_http_status(200) 
      expect(response).to have_http_status(:ok) 
    end
    
    it "should return a propper json" do
      article = create(:article)
      subject
      expect(json_data.length).to eq(1)
      expected = json_data.first
      aggregate_failures do
        expect(expected[:id]).to eq(article.id.to_s)
        expect(expected[:type]).to eq('article')
        expect(expected[:attributes]).to eq(
          title: article.title,
          content: article.content,
          slug: article.slug
          )
      end
    end

    it "should return the list of articles in a propper order" do
      older_article = create(:article, created_at: 1.hour.ago)
      recent_article = create(:article)
      subject
      ids = json_data.map { |item| item[:id].to_i }
      expect(ids).to eq([recent_article.id, older_article.id])
    end
    
    
  end
end
