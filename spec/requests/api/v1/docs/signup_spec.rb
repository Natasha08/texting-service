require 'swagger_helper'

describe 'api/v1/registrations', type: :request do
  path '/api/v1/auth/signup' do
    post('create user') do
      consumes "application/json"
      produces 'application/json'

        parameter name: :user, in: :body, schema: {
          type: :object,
          description: "user keys returned after user creation",

          properties: {
            user: {
              type: :object,
              properties: {
                email: { type: :string },
                password: { type: :string },
              }
            },
          },
          example: {
            user: {
              email: "natasha@example.com",
              password: "password"
            }
          },
          required: ["email", "password"]
        }

      response(200, 'successful') do
        schema type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: {
                type: :string
              }
            }
          },
          id: { type: :integer },
        },
        example: {
          user: {
            email: "natasha@example.com"
          }
        }
        run_test!
      end

      response(422, 'invalid request') do
        schema type: :string,
        properties: {
          error: :string
        },
        example: {
          error: "Email can't be blank"
        }
        run_test!
      end
    end
  end
end
