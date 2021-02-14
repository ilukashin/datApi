# frozen_string_literal: true

require 'json'
require 'yaml'
require 'byebug'

Dir[File.join('.', 'lib', '**', '*.rb')].sort.each { |f| require f }

class App
  attr_reader :jobs_configs, :filtered_configs, :db_config

  def initialize
    @jobs_configs = Dir[File.join('jobs', '**', '*.yml')].map { |f| YAML.safe_load(File.read(f), aliases: true) }
    @db_config = YAML.safe_load(File.read('./config/database.yml'))

    @filtered_configs = jobs_configs.select { |config| config['shedule'].eql?(ARGV[0]) }
  end

  def run
    filtered_configs.each do |config|
      puts "\n#{Time.now.strftime('%H:%M:%S %Y-%m-%d')} --- Start job: #{config['name']} --- \n"

      Job.new(config, db_config).do_job

      puts "\n#{Time.now.strftime('%H:%M:%S %Y-%m-%d')} --- Finish job: #{config['name']} --- \n\n"
    end
  end
end
