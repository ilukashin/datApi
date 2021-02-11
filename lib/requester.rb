require 'rest-client'
require 'json'

class Requester
  attr_reader :params, :method, :url, :headers

  def initialize(params)
    @params = params

    @method = params['method'].downcase.to_sym
    @url = params['url']
    @headers = params['headers']
  end

  def make_request
    response = RestClient.send(method, url, headers)
    JSON.parse(response.body)
  end
end
