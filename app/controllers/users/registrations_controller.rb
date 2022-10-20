# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController

  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        satus: { code: 200, message: 'Signed up successfully.',
                 data: UserSerializer.new(resource).serializable_hash[:data][:attributes] }
      }, status: :ok
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity

    end
  end
end
