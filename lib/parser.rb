class Parser
  attr_reader :rule, :root, :mapping, :primary_key, :mapping_keys
  attr_accessor :result

  def initialize(rule)
    @rule = rule
    @root = rule['root_element']
    @mapping = rule['mapping']
    @primary_key = mapping['primary_key']
    @mapping_keys = mapping['keys']

    @result = []
  end

  def parse(data)
    data_root = root && !root.eql?('.') ? data[root] : data

    data_root.each do |data_element|
      parsed_element = { primary_key => data_element[primary_key] }
      parse_keys(data_element, parsed_element)
      result << parsed_element
    end
    
    puts "Parsed #{data_root.count} elements."
    result
  end

  private

  def parse_keys(data_element, parsed_element)
    mapping_keys.each do |key|
      if key.is_a?(Hash)
        parse_hash_key(data_element, parsed_element, key)
      else
        parsed_element[key] = data_element[key]
      end
    end
  end

  def parse_hash_key(data_element, parsed_element, key_hash)
    key_hash.each do |key, value|
      parsed_element[key] = take_nested_value(data_element, value.split('.'))
    end
  end

  def take_nested_value(data, nested_value_path)
    data = data[nested_value_path.shift]
    return nil unless data

    return data if nested_value_path.empty?
    take_nested_value(data, nested_value_path)
  end

end
