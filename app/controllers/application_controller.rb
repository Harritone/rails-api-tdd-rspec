class ApplicationController < ActionController::API
   include JsonapiErrorsHandler

  ErrorMapper.map_errors!(
    'ActiveRecord::RecordNotFound' =>
      'JsonapiErrorsHandler::Errors::NotFound',
      "ActiveRecord::ActiveRecord::RecordInvalid" => "JsonapiErrorsHandler::Errors::Invalid"
  )
  rescue_from ::StandardError, with: lambda { |e| handle_error(e) }
  rescue_from ActiveRecord::RecordInvalid, with: lambda { |e| handle_validation_error(e) }

  def handle_validation_error(error)
    error_model = error.try(:model) || error.try(:record)
    mapped = JsonapiErrorsHandler::Errors::Invalid.new(errors: error_model.errors)
    render_error(mapped)
  end

  #  def handle_validation_error(error)
  #   error_model = error.try(:model) || error.try(:record)
  #   errors = error_model.errors.reduce([]) do |r, e|
  #     r << {
  #       source: { pointer: "/data/attributes/#{e.attribute}" },
  #       detail: e.message,
  #       status: 422,
  #       title: "Invalid request"
  #     }
  #   end
  #   render json: { errors: errors }, status: 422
  # end

  class AuthorizationError < StandardError; end

  rescue_from UserAuthenticator::AuthenticationError, with: :authenication_error
  rescue_from AuthorizationError, with: :authorization_error

  before_action :authorize!

  private

  def authorize!
    raise AuthorizationError unless current_user
  end

  def acces_token
    provided_token = request.authorization&.gsub(/\ABearer\s/, '')
    @access_token = AccessToken.find_by(token: provided_token)
  end

  def current_user
    @current_user = acces_token&.user
  end

  def authenication_error
    error = {
      "status"=> "401",
      "source"=> {"pointer"=> "/data/attributes/code"},
      "title"=> "Authentication code is invalid",
      "detail"=> "You must provide valid code in order to exchange it for token"
    }
    render json: {"errors": [error]}, status: 401
  end

  def authorization_error
    error = {
      "status"=> "403",
      "source"=> {"pointer"=> "/headers/authorization"},
      "title"=> "Not authorized",
      "detail"=> "You have no right to access this resource"
    }
    render json: {"errors": [error]}, status: 403
  end

end
