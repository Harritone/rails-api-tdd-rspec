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
    article = current_user.articles.build(article_params)
    article.save!
    render json: serializer.new(article), status: :created
  end

  def update
    article = current_user.articles.find(params[:id])
    article.update!(article_params)
    render json: serializer.new(article), status: :ok
  rescue ActiveRecord::RecordNotFound
    raise JsonapiErrorsHandler::Errors::Forbidden
  end

  def destroy
    article = current_user.articles.find(params[:id])
    article.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotFound
    raise JsonapiErrorsHandler::Errors::Forbidden
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
