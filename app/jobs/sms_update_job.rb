class SMSUpdateJob < ApplicationJob
  queue_as :default

  def perform message, id
    channel = "chat_channel/#{id}"
    ActionCable.server.broadcast channel, message
  end
end
