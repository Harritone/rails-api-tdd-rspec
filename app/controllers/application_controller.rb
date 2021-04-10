class ApplicationController < ActionController::API
  rescue_from UserAuthenticator::AuthenticationError, with: :authenication_error

  private
  def authenication_error
    error = {
      "status"=> "401",
      "source"=> {"pointer"=> "/data/attributes/code"},
      "title"=> "Authentication code is invalid",
      "detail"=> "You must provide valid code in order to exchange it for token"
    }
    render json: {"errors": [error]}, status: 401
  end
end
