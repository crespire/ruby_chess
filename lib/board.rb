#frozen_string_literal: true

# lib/board.rb

require_relative 'cell'

class Board
  def initialize
    @board = Array.new(8) { Array.new(8, Cell.new) }
  end
end