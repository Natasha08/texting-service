require 'rails_helper'

describe 'Text Messages' do
  context "#index" do
    let!(:text_messages) { create_list :text_message, 3 }

    before { get "/api/v1/text_messages" }

    it "responds with status 200" do
      expect(response.code).to eq("200")
      # expect(response_json).to include(text_messages)
    end
  end

  context "#create" do
    let(:sms_message_id) { 'k3i2-f02k-8dhq-v8wj' }

    before do
      stub_request(:post, "#{ENV.fetch('SMS_PROVIDER', nil)}/dev/provider1")
        .to_return({
          body: {message_id: sms_message_id}.to_json,
          headers: {"Content-Type" => "application/json"}
        })
      post "/api/v1/text_messages", params: {text: "This is a great message", to_number: "555-555-5555"}
    end

    it "responds with status 200" do
      text_message = TextMessage.find_by to_number: "555-555-5555"
      expect(response.code).to eq("200")
      expect(text_message.sms_message_id).to eq sms_message_id

      post "/api/v1/delivery_status", params: {message_id: text_message.sms_message_id, status: "delivered"}

      expect(response.code).to eq("204")
      updated_message = text_message.reload
      expect(updated_message.status).to eq "delivered"
      expect(updated_message.resolved).to eq true
      expect(updated_message.sms_message_id).to eq sms_message_id
    end
  end

  context "#delivery_status" do
    context "when there is a new status update" do
      let(:sms_message_id) { '2342-2993-f223-123v' }
      let!(:text_message) { create :text_message, sms_message_id: nil }

      before do
        stub_request(:post, "#{ENV.fetch('SMS_PROVIDER', nil)}/dev/provider1")
          .to_return({
            body: {message_id: sms_message_id}.to_json,
            headers: {"Content-Type" => "application/json"}
          })
      end

      it "it updates the text message" do
        SMSService.new(text_message).send

        post "/api/v1/delivery_status", params: {message_id: text_message.sms_message_id, status: "delivered"}

        expect(response.code).to eq("204")
        updated_message = text_message.reload
        expect(updated_message.status).to eq "delivered"
        expect(updated_message.resolved).to eq true
        expect(updated_message.sms_message_id).to eq sms_message_id
      end
    end

    context "text message fails to post to the provider" do
      let(:sms_message_id) { '3j29-j20f-f223-123v' }
      let!(:text_message) { create :text_message, sms_message_id: nil }

      before do
        stub_request(:post, "#{ENV.fetch('SMS_PROVIDER', nil)}/dev/provider1")
          .to_return({
            body: {status: 502, error: "something went wrong"}.to_json,
            headers: {"Content-Type" => "application/json"}
          })

        stub_request(:post, "#{ENV.fetch('SMS_PROVIDER', nil)}/dev/provider2")
          .to_return({
            body: {status: 204, message_id: sms_message_id}.to_json,
            headers: {"Content-Type" => "application/json"}
          })
      end

      it "it retries with the second provider" do
        SMSService.new(text_message).send

        expect(text_message.status).to eq nil
        expect(text_message.resolved).to eq false
        expect(text_message.sms_message_id).to eq sms_message_id

        post "/api/v1/delivery_status", params: {message_id: text_message.sms_message_id, status: "delivered"}

        updated_message = text_message.reload
        expect(response.code).to eq("204")
        expect(updated_message.status).to eq "delivered"
        expect(updated_message.resolved).to eq true
        expect(updated_message.sms_message_id).to eq sms_message_id
      end
    end

    context "text message fails to post to both providers" do
      let!(:text_message) { create :text_message, sms_message_id: nil }

      before do
        stub_request(:post, "#{ENV.fetch('SMS_PROVIDER', nil)}/dev/provider1")
          .to_return({
            body: {status: 502, error: "something went wrong"}.to_json,
            headers: {"Content-Type" => "application/json"}
          })

        stub_request(:post, "#{ENV.fetch('SMS_PROVIDER', nil)}/dev/provider2")
          .to_return({
            body: {status: 502, error: "something went wrong"}.to_json,
            headers: {"Content-Type" => "application/json"}
          })
      end

      it "it updates the text message" do
        SMSService.new(text_message).send

        expect(text_message.status).to eq "failure"
        expect(text_message.resolved).to eq true
        expect(text_message.sms_message_id).to be nil
      end
    end

    context "when the status update is old" do
      let(:original_status) { "delivered" }
      let!(:text_message) { create :text_message, status: original_status, resolved: true }

      it "it does not update the text message" do
        post "/api/v1/delivery_status", params: {message_id: text_message.sms_message_id, status: "failure"}

        expect(response.code).to eq("204")
        expect(text_message.status).to eq original_status
      end
    end
  end
end
