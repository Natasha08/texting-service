require 'rails_helper'

describe 'Signup' do
  let!(:email) { 'natasha@example.com' }

  context "#create" do
    it "creates a user" do
      expect do
        post "/api/v1/auth/signup", params: {user: {email: email, password: 'password'}}
      end.to change { User.count }.by 1

      user = response_json[:user]
      expect(user[:email]).to eq email
    end

    context "missing password" do
      it "sends an error message" do
        expect do
          post "/api/v1/auth/signup", params: {user: {email: email, password: ''}}
        end.to change { User.count }.by 0

        expect(response.code).to eq("422")
        expect(response_json).to_not have_key(:user)
        expect(response_json[:error]).to eq I18n.t('errors.login.password')
      end
    end

    context "missing email" do
      it "sends an error message" do
        expect do
          post "/api/v1/auth/signup", params: {user: {email: "", password: 'password'}}
        end.to change { User.count }.by 0

        expect(response.code).to eq("422")
        expect(response_json).to_not have_key(:user)
        expect(response_json[:error]).to eq I18n.t('errors.login.email')
      end
    end
  end
end
