class ApplicationController < ActionController::API
  include RackSessionFix
  respond_to :json
end
