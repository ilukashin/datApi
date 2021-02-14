# frozen_string_literal: true

require 'yaml'

class Saver
  attr_reader :params, :db_config, :connector

  def initialize(params, db_config)
    @params = params

    @db_config = db_config[params['name']]
    @connector = init_connector
  end

  def save(data)
    connector.save(data)

    puts "Saved data with PK: #{params['primary_key']} - #{data[params['primary_key']]}"
  end

  private

  def init_connector
    Object.const_get("#{db_config['connector'].capitalize}Connector").new(params, db_config)
  end
end
