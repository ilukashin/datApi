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
    return JSON.parse(response.body)

  rescue RestClient::Exception => e
    puts "Error: #{e.class} #{e.message}" , "Url: #{url}"

    return nil
  end
end
