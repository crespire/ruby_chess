# frozen_string_literal: true

# lib/movement.rb

require_relative 'chess'
require_relative 'board'
require_relative 'cell'
require_relative 'piece'
require_relative 'pieces/all_pieces'

class Movement
  def initialize(game)
    @board = game.board
    @game = game
  end

  def legal_moves(cell)
    return [] if cell.empty?

    piece = cell.piece
    moves = piece.moves(@board, cell.name)
    p moves
    destinations = []
    moves.each do |move|
      destinations += move.valid
    end

    destinations.map(&:name).sort
  end

  # Start with Knight and King. Those should be the easiest to get working for possible moves.
end
