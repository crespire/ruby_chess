# frozen_string_literal: true

# lib/save.rb

require 'yaml'

class Save
  def initialize; end

  def self.serialize(obj = {})
    instance_variables.map do |var|
      obj[var] = instance_variable_get(var)
    end

    YAML.dump(obj)
  end

  def self.save_to_file(filename, dump)
    File.open("save/#{filename}", 'w') { |f| f.write(dump) }
  end

  def self.load_from_file(filename)
    File.read("save/#{filename}")
  end
end