# frozen_string_literal: true

# lib/pieces/queen.rb

class Queen < Piece
  # Clockwise from north @ 12
  OFFSETS = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]].freeze
  STEPS = 7

  def all_paths(board, origin)
    moves = []
    OFFSETS.each { |offset| moves << Move.new(board, origin, offset, STEPS) }
    moves
  end

  def valid_paths(board, origin)
    all_paths(board, origin).reject(&:dead?)
  end

  def moves(board, origin)
    result = []
    valid_paths(board, origin).each { |move| result += move.valid }
    result
  end

  def slides?
    true
  end
end
