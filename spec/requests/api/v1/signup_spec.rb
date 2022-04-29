require 'rails_helper'

describe 'Signup' do
  context "#create" do
    let(:email) { 'natasha@example.com' }
    it "creates a user" do
      user_params = {user: {email: email, password: 'password'}}

      expect do
        post "/api/v1/auth/signup", params: user_params
      end.to change { User.count }.by 1

      user = response_json[:user]
      expect(user[:email]).to eq email
    end

    context "missing password" do
      it "sends an error message" do
        user_params = {user: {email: email, password: ''}}
        post "/api/v1/auth/signup", params: user_params

        expect do
          post "/api/v1/auth/signup", params: user_params
        end.to change { User.count }.by 0

        expect(response.code).to eq("422")
        expect(response_json).to_not have_key(:user)
        expect(response_json[:error]).to eq "Password can't be blank"
      end
    end

    context "missing email" do
      it "sends an error message" do
        user_params = {user: {email: "", password: 'password'}}
        post "/api/v1/auth/signup", params: user_params

        expect do
          post "/api/v1/auth/signup", params: user_params
        end.to change { User.count }.by 0

        expect(response.code).to eq("422")
        expect(response_json).to_not have_key(:user)
        expect(response_json[:error]).to eq "Email can't be blank"
      end
    end
  end
end
