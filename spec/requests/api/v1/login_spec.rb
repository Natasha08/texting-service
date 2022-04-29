require 'rails_helper'

describe 'Login' do
  context "#create" do
    let(:user) { create :user }
    let(:stubbed_token) { "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo5OH0.2eBHHKcyyENtMJkFZz_I9mPHSf4vu9JqCbjS0g9o31o" }

    it "responds with a jwt token" do
      expect(JwtService).to receive(:issue).with({user_id: user.id}).and_return(stubbed_token)

      post "/api/v1/auth/login", params: {email: user.email, password: 'password'}

      expect(response_json[:token]).to eq stubbed_token
    end

    context "when the password is incorrect" do

      it "responds with a 422 error" do
        post "/api/v1/auth/login", params: {email: user.email, password: 'incorrect password'}
        expect(response.code).to eq("422")
        expect(response_json).to_not have_key(:user)
        expect(response_json[:error]).to eq I18n.t('errors.login.failure')
      end
    end

    context "when the email is incorrect" do
      it "responds with a 404 error" do
        post "/api/v1/auth/login", params: {email: 'incorrect_email@example.com', password: 'password'}
        expect(response.code).to eq("422")
        expect(response_json).to_not have_key(:user)
        expect(response_json[:error]).to eq I18n.t('errors.login.failure')
      end
    end
  end
end
