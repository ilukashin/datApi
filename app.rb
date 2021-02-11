require 'json'
require 'yaml'

Dir[File.join('.', 'lib', '**', '*.rb')].each { |f| require f }

class App
  attr_reader :jobs_configs, :filtered_configs, :db_config

  def initialize
    @jobs_configs = Dir[File.join('jobs', '**', '*.yml')].map { |f| YAML.load(File.read(f)) }
    @db_config = YAML.load(File.read('./config/database.yml'))

    @filtered_configs = jobs_configs.select { |config| config['shedule'].eql?(ARGV[0])
  end

  def run
    jobs_configs.each do |config|
      Job.new(config, db_config).do_job
    end
  end

end
