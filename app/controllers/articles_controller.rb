class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: %i[index show]

  include Paginable

  def index
    paginated = paginate(Article.recent)
    render_collection(paginated)
  end

  def show
    render json: serializer.new(Article.find(params[:id]))
  end

  def create
    article = Article.new(article_params)
    article.save!
    render json: serializer.new(article), status: :created
  end

  def serializer
    ArticleSerializer
  end

  private

  def article_params
     params.require(:data).require(:attributes).
      permit(:title, :content, :slug) ||
    ActionController::Parameters.new
  end

end
