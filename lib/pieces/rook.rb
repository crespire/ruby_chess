# frozen_string_literal: true

# lib/pieces/rook.rb

class Rook < Piece
  def moves(board, origin)
    moves = []
    # Clockwise from north @ 12
    offsets = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    offsets.each do |offset|
      moves << Move.new(board, origin, offset, 7)
    end
    moves
  end
end