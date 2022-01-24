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
    psuedo = piece.moves(@board, cell.name)

    # Psuedo contains cells, so we can actually ask questions about it.

    # Returns names.
    names = psuedo.map(&:name).sort
  end
end
