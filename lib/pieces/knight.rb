# frozen_string_literal: true

# lib/pieces/knight.rb

class Knight < Piece
  # Clockwise from north @ 12
  OFFSETS = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]].freeze

  def all_moves(board, origin)
    moves = []
    OFFSETS.each { |offset| moves << Move.new(board, origin, offset) }
    moves
  end

  def moves(board, origin)
    all_moves.reject(&:dead?) # Remove empty moves
  end
end
