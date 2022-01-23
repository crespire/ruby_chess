# frozen_string_literal: true

# lib/pieces/pawn.rb

class Pawn < Piece
  def moves(board, origin)
    moves = []
    rank_dir = white? ? 1 : -1
    offsets = [[0, rank_dir], [1, rank_dir], [-1, rank_dir]]
    offsets.each { |offset| moves << Move.new(board, origin, offset) }
    moves.reject(&:dead?) # Remove empty moves
  end
end