module RequestHelper
  def response_json
    JSON.parse(response.body).tap do |response_json|
      case response_json
      when Array
        response_json.map!(&:with_indifferent_access)
      when Hash
        response_json.deep_symbolize_keys!
      end
    end
  end
end

RSpec.configure do |config|
  config.include RequestHelper, type: :request
end
