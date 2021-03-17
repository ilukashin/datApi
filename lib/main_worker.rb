# frozen_string_literal: true

class MainWorker
  attr_reader :params

  def initialize(params)
    @params = params
    @workers = {}
  end

  def transform(data)
    params.each { |worker_name| workers(worker_name).run(data) } if params

    data
  end

  private

  def workers(worker_name)
    @workers[worker_name] = Object.const_get(worker_name.split('_').map(&:capitalize).join).new unless @workers[worker_name]

    @workers[worker_name]
  end
end
