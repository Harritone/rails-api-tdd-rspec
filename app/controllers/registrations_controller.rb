class RegistrationsController < ApplicationController
  skip_before_action :authorize!, only: :create
  def create
    user = User.new(registration_params.merge(provider: 'standard'))
    user.save!
    render json: user, status: :created
  end

  private 
  def registration_params 
    params.dig(:data, :attributes).permit(:login, :password) || 
    ApplicationController::Parameters.new
  end
end