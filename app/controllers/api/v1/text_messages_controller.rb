class API::V1::TextMessagesController < ApplicationController
  before_action :require_login, except: :delivery_status

  def index
    text_messages = policy_scope TextMessage.all
    render json: text_messages
  end

  def create
    text_message = TextMessage.new(create_message_params.merge(sender: current_user, status: 'pending'))
    authorize text_message

    SMSService.new(text_message, current_user).send

    if text_message.save
      render json: text_message
    else
      render json: {
        error: {
          message: "#{I18n.t('sms_status.failed_save')} #{@text_message.errors.full_messages.to_sentence}"
        }
      }
    end
  end

  def delivery_status
    @text_message = TextMessage.find_by(sms_message_id: params[:message_id])

    return head :no_content if @text_message.blank?
    return head :no_content if @text_message.resolved

    manage_status_changes
    head :no_content
  end

  private

  def notify **kwargs
    SMSUpdateJob.perform_later kwargs, @sms_service.current_user_id
  end

  def delivered_status_response
    if @text_message.update update_message_params.merge(resolved: true)
      notify message: @text_message
    else
      notify error: {message: "#{I18n.t('sms_status.failed_save')} #{@text_message.errors.full_messages.to_sentence}"}, message: @text_message
    end
  end

  def failed_status_response
    if @sms_service.max_attempts_reached?
      @text_message.update(status: "failed", resolved: true)
      notify error: {message: I18n.t('sms_status.max_attempts_reached')}, message: @text_message
    else
      @text_message.update(status: "failed")
      @sms_service.retry_send
      notify error: {message: I18n.t('sms_status.failed_and_will_retry')}, message: @text_message
    end
  end

  def invalid_status_response
    @text_message.update(status: "invalid", resolved: true)
    notify error: {message: I18n.t('sms_status.invalid_phone_number')}, message: @text_message
  end

  def unknown_status_error
    @text_message.update(status: "failed", resolved: true)
    notify error: {message: I18n.t('sms_status.unknown_status_error')}, message: @text_message
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
