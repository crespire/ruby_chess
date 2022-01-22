# frozen_string_literal: true

# lib/pieces/bishop.rb

class Bishop < Piece
  def moves(board, origin)
    moves = []
    # Clockwise from north @ 12
    offsets = [[1, 1], [1, -0], [-1, -1], [-1, 1]]
    offsets.each do |offset|
      moves << Move.new(board, origin, offset, 7)
    end
    moves
  end

  def slides?
    true
  end
end
