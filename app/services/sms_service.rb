require 'httparty'

class SMSService
  include HTTParty
  base_uri ENV.fetch('SMS_PROVIDER', nil)

  @@instances = []

  def initialize text_message
    @@instances << self
    @text_message = text_message
    @attempts = 0
    @retry_attempted = false

    @params = {
      message: text_message[:text],
      to_number: text_message[:to_number],
      callback_url: "#{callback_url}/api/v1/delivery_status"
    }
  end

  def self.find_instance message_id
    @@instances.find { |i| i.message_id == message_id }
  end

  def retry_send
    @retry_attempted = true
    @attempts = 0
    send
  end

  def message_id
    @text_message.sms_message_id
  end

  def max_attempts_reached?
    @text_message.status == "failed" && @retry_attempted
  end

  def send
    if @params[:to_number].blank? || @params[:message].blank?
      {status: 'invalid'}
      # send action cable message
    else
      @attempts += 1

      begin
        send_message
      rescue
        retry if (@attempts += 1) < 3

        if @retry_attempted
          # send action cable message
          @text_message.update(status: "failure", resolved: true)
        else
          retry_send
        end
      end
    end
  end

  private

  def send_message
    post_path = @retry_attempted ? retry_path : path
    response = self.class.post(post_path, options).parsed_response.deep_symbolize_keys!

    if response[:message_id]
      @text_message.update sms_message_id: response[:message_id]
      # send action cable message
    else
      raise "message failed to post"
    end
  end

  def path
    '/dev/provider1'
  end

  def retry_path
    '/dev/provider2'
  end

  def headers
    {"CONTENT_TYPE" => "application/json"}
  end

  def options
    {body: @params.to_json, headers: headers}
  end

  def callback_url
    ENV.fetch('SMS_CALLBACK_DOMAIN', nil)
  end
end
