# frozen_string_literal: true

# lib/pieces/knight.rb

class Knight < Piece
  def moves(board, origin)
    moves = []
    # Clockwise from north @ 12
    offsets = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]] 
    offsets.each do |offset|
      moves << Move.new(board, origin, offset)
    end
    moves
  end
end
