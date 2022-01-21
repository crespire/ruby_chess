# frozen_string_literal: true

# lib/pieces/pawn.rb

class Pawn < Piece

  def moves(board, origin)
    moves = []
    rank_dir = white? ? 1 : -1
    offsets = [[0, rank_dir], [1, rank_dir], [-1, rank_dir]]

    offsets.each_with_index do |offset, i|
      moves << Move.new(board, origin, offset, (i.zero? ? 2 : 1))
    end

    # Currently all moves are returned
    # We need to make sure invalid moves are discarded.
    # So, for a pawn, for example, empty diagonals are not valid.
    moves
  end
end