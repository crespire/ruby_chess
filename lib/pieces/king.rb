# frozen_string_literal: true

# lib/pieces/king.rb

class King < Piece
  def moves(board, origin)
    moves = []
    # Clockwise from north @ 12
    offsets = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
    offsets.each { |offset| moves << Move.new(board, origin, offset) }
    moves.reject(&:dead?) # Remove empty moves
  end
end