require 'rails_helper'

describe 'Messages' do
  context "#index" do
    before { get "/api/v1/messages" }

    it "responds with status 200" do
      expect(response.code).to eq("200")
      expect(response_json).to include({id: 24, title: "Smoke test for test setup"})
    end
  end
end
