# frozen_string_literal: true

# lib/move.rb

class Move
  def initialize(board, origin, offset, steps = 1)
    @origin = origin

    cells(board, offset, steps)
  end

  def possible_moves
    return @cells if @cells.empty?

    # Do stuff to figure out what moves are possible. 
    # ie, can a pawn capture forward diagonal? If so, then it's a possible move. If not, then it's not possible.
  end

  def dead?
    @cells.empty?
  end

  private

  def cells(board, offset, steps)
    return @cells if @cells

    @cells ||= []
    steps.times do
      destination = board.cell(@origin, offset[0], offset[1])
      break unless destination.is_a?(Cell)

      @cells << destination if destination.empty? || destination.hostile?(board.cell(@origin))
    end
    
    @cells
  end
end