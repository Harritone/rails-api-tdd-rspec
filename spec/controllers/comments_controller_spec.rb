require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:article) { create :article }

  describe "GET #index" do
    subject { get :index, params: { article_id: article.id } }
    it "renders a successful response" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should retrurn only comments belonging to article' do
      comment = create :comment, article: article
      create :comment
      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(comment.id.to_s)
    end

    it "should paginate results" do
      comments = create_list :comment, 3, article: article
      get :index, params: { article_id: article.id, page: { number: 2, size: 1 } }
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(comments.second.id.to_s)
    end

    it 'should have proper json' do
      comment = create :comment, article: article
      subject 
      expect(json_data.first[:attributes]).to eq(
        {
          content: comment.content
        }
      )
    end
  end
  
  describe "POST /create" do

    let(:valid_attributes) { { content: 'My awesome content' } }
    let(:invalid_attributes) { { content: '' } }

    context 'when not authorized' do
      subject { post :create, params: { article_id: article.id } } 
      it_behaves_like 'forbidden_request'
    end

    context 'when authorized' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}"}

      context "with valid parameters" do
        it "creates a new Comment" do
          expect {
            post :create, params: {article_id: article.id, comment: valid_attributes}
          }.to change(Comment, :count).by(1)
        end
  
        it "renders a JSON response with the new comment" do
          post :create, params: {article_id: article.id, comment: valid_attributes } 
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(response.location).to eq(article_url(article))
        end
      end
      
      context "with invalid parameters" do
        subject do
          post :create, params: { article_id: article.id, comment: invalid_attributes } 
        end

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "should render a JSON response with errors for the new comment" do
          subject
          expect(json[:errors]).to include({
            "status": 422,
            "source": { "pointer": "/data/attributes/content" },
            "detail":  "can't be blank",
            "title": 'Invalid request'
          })
        end
      end
    end
  end
end
