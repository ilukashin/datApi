# frozen_string_literal: true

require 'rest-client'
require 'json'

class Requester
  attr_reader :params, :method, :url, :timeout
  attr_accessor :headers, :last_result, :result

  def initialize(params)
    @params = params

    @method = params['method'].downcase.to_sym
    @url = params['url']
    @headers = params['headers']
    @timeout = params['timeout'] || 120

    @last_result
    @result = []
  end

  def extract(parser)
    loop do
      data = execute
      parsed_data = parser.parse(data) if data
      yield(parsed_data) if block_given?

      break unless repeat
    end

    result
  end

  private

  def execute
    puts method, url, headers.inspect

    response = RestClient::Request.execute( method: method, url: url, headers: headers, timeout: timeout)
    self.last_result = JSON.parse(response.body)

    last_result
  rescue RestClient::Exception => e
    puts "Error: #{e.class} #{e.message}", "Url: #{url}"
    nil
  end

  def repeat
    return false unless last_result
    return false unless params['repeat']

    puts "Repeat step: #{repeat_step}"

    self.headers['params'][repeat_param] += repeat_step

    break_point > current_repeat_param
  end

  def repeat_step
    params['repeat']['step']
  end

  def repeat_param
    params['repeat']['on_param']
  end

  def break_point
    last_result[params['repeat']['break_point']].to_i
  end

  def current_repeat_param
    headers['params'][repeat_param]
  end
end
