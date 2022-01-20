# frozen_string_literal: true

# lib/movement.rb

require_relative 'chess'

class Movement
  def initialize(game)
    @board = game.board
    @game = game
  end

  def legal_moves(cell)
    return [] if cell.empty?

    # Get possible moves, then remove invalid ones.
  end

  def possible_moves(cell)
    return [] if cell.empty?

    # Generate all possible moves based on the rules of each piece.
  end
end