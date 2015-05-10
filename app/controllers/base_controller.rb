# This controller doesn't expose any routes, but is used as a base for the
# rest of the application's controllers.
class BaseController < Sinatra::Base
  set :raise_errors, false
  set :show_exceptions, false

  before { content_type :json }

  def parse_json(body)
    JSON.parse(body)
  rescue JSON::JSONError => ex
    raise MalformedRequestError, ex
  end

  def req_body
    request.body.tap(&:rewind).read
  end
end
