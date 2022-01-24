# frozen_string_literal: true

# lib/pieces/pawn.rb

class Pawn < Piece
  def initialize(fen)
    super(fen)
    rank_dir = (white? ? 1 : -1).freeze
    @offsets = [[0, rank_dir], [1, rank_dir], [-1, rank_dir]].freeze
  end

  def all_moves(board, origin)
    moves = []
    @offsets.each_with_index { |offset, i| moves << Move.new(board, origin, offset, i.zero? ? 2 : 1) }
    moves
  end

  def moves(board, origin)
    all_moves(board, origin).reject(&:dead?) # Remove empty/first-cell blocked moves
  end
end