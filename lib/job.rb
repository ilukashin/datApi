# frozen_string_literal: true

class Job
  attr_reader :config, :db_config

  def initialize(config, db_config)
    @config = config

    @db_config = db_config
  end

  def do_job
    request? ? request_work : db_work
  end

  private

  def request?
    config['source'].key?('request')
  end

  def request_work
    requester.extract(parser) do |parsed_data|
      parsed_data.each { |data| saver.load(worker.transform(data)) } if parsed_data
    end
  end

  def db_work
    selecter.select.each { |data| saver.load(worker.transform(data)) }
  end

  def selecter
    @selecter_obj ||= Selecter.new(config['source']['database'], db_config)
  end


  def requester
    @requester_obj ||= Requester.new(config['source']['request'])
  end

  def parser
    @parser_obj ||= Parser.new(config['source']['result_parser'])
  end

  def worker
    @worker_obj ||= MainWorker.new(config['works'])
  end

  def saver
    @saver_obj ||= Saver.new(config['save'], db_config)
  end
end
