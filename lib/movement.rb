# frozen_string_literal: true

# lib/movement.rb

require_relative 'chess'

class Movement
  def initialize(game)
    @board = game.board
    @game = game
  end

  def valid_moves(cell)
    return [] if cell.empty?
  end
end
  