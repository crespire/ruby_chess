#frozen_string_literal: true

# lib/board.rb

class Board
  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
  end
end