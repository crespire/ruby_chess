# frozen_string_literal: true

# lib/pieces/rook.rb

class Rook < Piece
  # Clockwise from north @ 12
  OFFSETS = [[0, 1], [1, 0], [0, -1], [-1, 0]].freeze
  STEPS = 7

  def all_moves(board, origin)
    moves = []
    OFFSETS.each { |offset| moves << Move.new(board, origin, offset, STEPS) }
    moves
  end

  def moves(board, origin)
    all_moves(board, origin).reject(&:dead?) # Remove empty/first-cell blocked moves
  end

  def slides?
    true
  end
end