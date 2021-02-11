class Job
  attr_reader :config, :job_name, :db_config, :requester, :parser, :worker, :saver

  def initialize(config, db_config)
    @config = config
    @job_name = config['name'] 

    @db_config = db_config

    @requester = Requester.new(request_params)
    @parser = Parser.new(parser_params)
    @worker = Worker.new(worker_params)
    @saver = Saver.new(save_params, db_config)
  end

  def do_job
    puts "Start job: #{job_name}"
    #testing parser
    # data = JSON.parse(File.read('t.json'))

    data = requester.make_request
    parsed_data = parser.parse(data)

    parsed_data.each do |data|
      data_to_save = worker.execute(data)
      saver.save(data_to_save)
    end 
    puts "Finished job: #{job_name}"
  end

  private

  def request_params
    config['source']['request']
  end

  def parser_params
    config['source']['result_parser']
  end

  def worker_params
    config['work']
  end

  def save_params
    config['save']
  end

end
