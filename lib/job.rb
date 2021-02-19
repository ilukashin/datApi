# frozen_string_literal: true

class Job
  attr_reader :config, :db_config

  def initialize(config, db_config)
    @config = config

    @db_config = db_config
  end

  def do_job
    parsed_data = requester.make_request(parser)

    parsed_data.each do |data|
      data_to_save = worker.execute(data)
      saver.save(data_to_save)
    end
  end

  private

  def requester
    Requester.new(config['source']['request'])
  end

  def parser
    Parser.new(config['source']['result_parser'])
  end

  def worker
    MainWorker.new(config['works'])
  end

  def saver
    Saver.new(config['save'], db_config)
  end
end
