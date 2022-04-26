class Api::V1::MessagesController < ApplicationController
  def index
    render json: [{id: 24, title: "Smoke test for test setup"}]
  end
end
