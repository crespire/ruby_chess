# frozen_string_literal: true

# lib/pieces/king.rb

class King < Piece
  # Clockwise from north @ 12
  OFFSETS = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]].freeze
  STEPS = 1

  attr_accessor :moved

  def initialize(fen)
    super(fen)
    @moved = false
  end

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
end
