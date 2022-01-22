# frozen_string_literal: true

# lib/move.rb

class Move
  include Enumerable

  def initialize(board, origin, offset, steps = 1)
    @origin = origin.is_a?(Cell) ? origin : board.cell(origin)

    cells(board, offset, steps)
  end

  def dead?
    @cells.empty?
  end

  def length
    return nil unless defined?(@cells)

    @cells.length
  end

  def each(&block)
    return unless defined?(@cells)

    @cells.each(&block)
  end

  def path_to_enemy; end

  def to_friendly; end

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