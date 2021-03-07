class Selecter
  attr_accessor :params, :db_config, :query

  def initialize(params, db_config)
    @params = params
    @db_config = db_config[params['name']]
    @query = params['query']

    @connector = init_connector
  end

  def select
    data = @connector.select(query).to_a

    data
  end

  private

  def init_connector
    Object.const_get("#{db_config['connector'].capitalize}Connector").new(params, db_config)
  end
end
