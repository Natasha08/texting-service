class API::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :require_login

  private

  def respond_with resource, _opts={}
    register_success && return if resource.persisted?

    register_failed
  end

  def register_success
    render json: {user: resource, status: :ok}
  end

  def register_failed
    render json: {error: resource.errors.full_messages.to_sentence}, status: 422
  end
end
