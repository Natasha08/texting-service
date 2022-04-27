class Api::V1::TextMessagesController < ApplicationController
  INVALID_STATUSES = ["invalid", "failed"]

  def index
    render json: TextMessage.all
  end

  def create
    text_message = TextMessage.new(create_message_params)
    SMSService.new(text_message).send

    render json: text_message
  end

  def delivery_status
    @text_message = TextMessage.find_by(sms_message_id: params[:message_id])
    return head :no_content if @text_message.resolved

    manage_status_changes
    head :no_content
  end

  private

  def notify(**kwargs)
    # send action cable message
  end

  def delivered_status_response
    if @text_message.update update_message_params.merge(resolved: true)
      notify message: @text_message
    else
      notify error: { message: "#{t('sms_status.failed_save')} #{@text_message.errors.full_messages.to_sentence}" }
    end
  end

  def failed_status_response
    if @sms_service.max_attempts_reached?
      @text_message.update(status: "failed", resolved: true)
      notify error: { message: t('sms_status.max_attempts_reached') }
    else
      @text_message.update(status: "failed")
      @sms_service.retry_send
      notify error: { message: t('sms_status.failed_and_will_retry')}
    end
  end

  def invalid_status_response
    @text_message.update(status: "invalid", resolved: true)
    notify error: { message: t('sms_status.invalid_phone_number') }
  end

  def unknown_status_error
    notify error: { message: t('sms_status.unknown_status_error')}
  end

  def manage_status_changes
    @sms_service = SMSService.find_instance(@text_message.sms_message_id)

    case params[:status]
    when "invalid"
      invalid_status_response
    when "failed"
      failed_status_response
    when "delivered"
      delivered_status_response
    else
      unknown_status_error
    end
  end

  def create_message_params
    params.permit(:to_number, :text)
  end

  def update_message_params
    params.permit(:status)
  end
end
