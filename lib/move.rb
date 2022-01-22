# frozen_string_literal: true

# lib/move.rb

class Move
  def initialize(board, origin, offset, steps = 1)
    @origin = origin.is_a?(Cell) ? origin : board.cell(origin)

    cells(board, offset, steps)
  end

  def dead?
    @cells.empty?
  end

  def length
    return nil unless @cells

    @cells.length
  end

  def to_capture; end

  def to_obstruction; end

  def clear_moves; end

  private

  def cells(board = nil, offset = nil, steps = nil)
    return @cells if @cells
    return if board.nil?

    @cells ||= []
    next_cell = @origin
    steps.times do
      destination = board.cell(next_cell.name, offset[0], offset[1])
      break unless destination.is_a?(Cell)

      @cells << destination
      next_cell = destination
    end
    @cells
  end
end