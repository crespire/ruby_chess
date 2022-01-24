# frozen_string_literal: true

# lib/pieces/pawn.rb

class Pawn < Piece
  def initialize(fen)
    super(fen)
    rank_dir = (white? ? 1 : -1).freeze
    @offsets = [[0, rank_dir], [1, rank_dir], [-1, rank_dir]].freeze
  end

  def all_paths(board, origin)
    home_rank = (white? ? 2 : 7)
    step = origin.chars[1].to_i == home_rank ? 2 : 1
    moves = []
    @offsets.each_with_index { |offset, i| moves << Move.new(board, origin, offset, i.zero? ? step : 1) }
    moves
  end

  def valid_paths(board, origin)
    all_paths(board, origin).reject(&:dead?) # Remove empty/first-cell blocked moves
  end

  def moves(board, origin)
    result = []
    valid_paths(board, origin).each { |move| result += move.valid }
    result
  end

  def captures(board, origin)
    moves = all_paths(board, origin)
    moves.shift
    result = []
    moves.each { |move| result += move.valid }
    result
  end
end