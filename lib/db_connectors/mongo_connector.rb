# frozen_string_literal: true

require 'mongo'

class MongoConnector
  attr_reader :url, :db, :table, :primary_key, :client, :collection

  def initialize(params, config)
    @url = config['url']
    @db = params['db']
    @table = params['table']

    @primary_key = params['primary_key']

    @client = Mongo::Client.new([url], database: db)
    @collection = client[table.to_sym]
  end

  def save(data)
    save_or_update(data)
  end

  private

  def save_or_update(data)
    collection.find_one_and_update({ primary_key.to_sym => data[primary_key] }, data, { upsert: true })
  end
end
