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
    
    it "should paginate results" do
      article1, article2, article3 = create_list(:article, 3)
      get :index, params: { page: { number: 2, size: 1 } }
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(article2.id.to_s)
    end
    
    it "should contain pagination links in the response" do
      article1, article2, article3 = create_list(:article, 3)
      get :index, params: { page: { number: 2, size: 1 } }
      expect(json[:links].length).to eq(5)
      expect(json[:links].keys).to contain_exactly(
        :first, :prev, :next, :last, :self
        )
      
    end
  end

  describe '#show' do
    let(:article) { create :article }
    subject { get :show, params: { id: article.id } }

    before { subject }

    it 'should return success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      aggregate_failures do
        expect(json_data[:id]).to eq(article.id.to_s)
        expect(json_data[:type]).to eq('article')
        expect(json_data[:attributes]).to eq({
            "title": article.title,
            "content": article.content,
            "slug": article.slug
        })
      end
    end
  end

  describe "#create" do
    subject { post :create }
    context 'when no code provided' do
      it_behaves_like 'forbidden_request'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_request'
    end

    context "when authorized" do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }
      context "when invalid parameters provided" do
        let(:invalid_attributes) do
          {
            "data" => {
              "attributes" => {
                "title" => "",
                "content" => "",
              },
            },
          }
        end
        subject { post :create, params: invalid_attributes }
        it "should return 422 status code" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "should return proper error json" do
          subject
          expect(json[:errors]).to include(
            {
              "source": { "pointer": "/data/attributes/title" },
              "detail": "can't be blank",
              "status": 422,
              "title": "Invalid request",
            },
            {
              "source": { "pointer": "/data/attributes/content" },
              "detail": "can't be blank",
              "status": 422,
              "title": "Invalid request",
            },
            {
              "source": { "pointer": "/data/attributes/slug" },
              "detail": "can't be blank",
              "status": 422,
              "title": "Invalid request",
            }
          )
        end
      end

       context "when success request sent" do
        let(:user) { create :user }
        let(:access_token) { user.create_access_token }
        before { request.headers["authorization"] = "Bearer #{access_token.token}" }

        let(:valid_attributes) do
          {
            "data": {
              "attributes": {
                "title": "Awesome article",
                "content": "Super content",
                "slug": "awesome-article",
              },
            },
          }
        end

        subject { post :create, params: valid_attributes }

        it "should have 201 status code" do
          subject
          expect(response).to have_http_status(:created)
        end

        it "should have proper json body" do
          subject
          expect(json_data[:attributes]).to include(
            valid_attributes[:data][:attributes]
          )
        end

        it "should create the article" do
          expect { subject }.to change { Article.count }.by(1)
        end
      end
    end
  end

  describe '#update' do
    let(:user) { create :user }
    let(:article) { create :article, user: user }
    let(:access_token) { user.create_access_token }

    subject { patch :update, params: {id: article.id} }

    context 'when no code provided' do
      it_behaves_like 'forbidden_request'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_request'
    end
    
    context "when trying to update not owned article" do
      let(:other_user) { create :user }
      let(:other_article) { create :article, user: other_user }

      subject { patch :update, params: { id: other_article.id } } 
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }

      it_behaves_like 'forbidden_request'
    end

    context "when authorized" do
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }
      context "when invalid parameters provided" do
        let(:invalid_attributes) do
          {
            "data" => {
              "attributes" => {
                "title" => "",
                "content" => "",
              },
            },
          }
        end
        
        subject do
          patch :update, params: invalid_attributes.merge(id: article.id)
        end

        it "should return 422 status code" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "should return proper error json" do
          subject
          expect(json[:errors]).to include(
            {
              "source": { "pointer": "/data/attributes/title" },
              "detail": "can't be blank",
              "status": 422,
              "title": "Invalid request",
            },
            {
              "source": { "pointer": "/data/attributes/content" },
              "detail": "can't be blank",
              "status": 422,
              "title": "Invalid request",
            },
          )
        end
      end

       context "when success request sent" do
        # let(:user) { create :user }
        # let(:access_token) { user.create_access_token }
        before { request.headers["authorization"] = "Bearer #{access_token.token}" }

        let(:valid_attributes) do
          {
            "data": {
              "attributes": {
                "title": "Awesome article",
                "content": "Super content",
                "slug": "awesome-article",
              },
            },
          }
        end

        subject { patch :update, params: valid_attributes.merge(id: article.id) }

        it "should have 200 status code" do
          subject
          expect(response).to have_http_status(:ok)
        end

        it "should have proper json body" do
          subject
          expect(json_data[:attributes]).to include(
            valid_attributes[:data][:attributes]
          )
        end

        it "should update the article" do
          subject
          expect(article.reload.title).to eq(
            valid_attributes[:data][:attributes][:title]
          )
        end
      end
    end
  end

  describe '#destroy' do
    let(:user) { create :user }
    let(:article) { create :article, user: user }
    let(:access_token) { user.create_access_token }

    subject { delete :destroy, params: {id: article.id} }

    context 'when no code provided' do
      it_behaves_like 'forbidden_request'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_request'
    end
    
    context "when trying to delete not owned article" do
      let(:other_user) { create :user }
      let(:other_article) { create :article, user: other_user }

      subject { delete :destroy, params: { id: other_article.id } } 
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }

      it_behaves_like 'forbidden_request'
    end

    context "when authorized" do
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }

      context "when success request sent" do
        before { request.headers["authorization"] = "Bearer #{access_token.token}" }
        
        it 'should have 204 status code' do
          subject 
          expect(response).to have_http_status(:no_content)
        end

        it 'should have empty json body' do
          subject
          expect(response.body).to be_blank
        end

        it 'should delete the article' do
          article
          expect{ subject }.to change{ Article.count }.by(-1)
        end
      end
    end
  end
end
