class ChatChannel < ApplicationCable::Channel
  def subscribed
    @current_user = current_user
    stream_from "chat_channel/#{@current_user.id}" if @current_user
  end

  def unsubscribed
    stop_stream_from "chat_channel/#{@current_user.id}"
  end
end
