# frozen_string_literal: true

# lib/pieces/king.rb

class King < Piece
  def moves(board = nil, origin = nil)
    moves = []
    # Clockwise from north @ 12
    offsets = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
    offsets.each do |offset|
      moves << Move.new(board, origin, offset)
    end
    moves
  end
end