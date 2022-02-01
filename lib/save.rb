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
    File.open("#{filename}.yml", 'w') { |f| f.write(dump) }
  end

  def self.load_from_file(filename)
    YAML.safe_load(File.read("#{filename}.yml"), [Bishop, King, Knight, Pawn, Queen, Rook, Board, Castle, Cell, Checkmate, Chess, Move, Movement, Piece, Save, UI], [], true)
  end
end