# frozen_string_literal: true

# lib/move.rb
require 'forwardable'

class Move
  include Enumerable
  extend Forwardable

  def_delegators :@cells, :<<, :&, :length, :each, :union, :uniq
  attr_reader :cells

  def initialize(board, origin, offset, steps)
    @origin = origin.is_a?(Cell) ? origin : board.cell(origin)
    @cells ||= build_move(board, offset, steps)
  end

  def dead?
    out_of_bounds? || blocked?
  end

  def out_of_bounds?
    @cells.empty?
  end

  def blocked?
    valid.empty?
  end

  def enemies
    return unless defined?(@cells)

    @cells.count { |cell| @origin.hostile?(cell) }
  end

  def valid
    return path_clear unless capture? || friendly?

    path_obstructed
  end

  def valid_xray
    return [] unless enemies > 1

    result = []
    path = @cells.dup
    current_cell = path.shift
    found = 0
    loop do # We only care about the first two enemies for xray
      result << current_cell
      current_cell = path.shift
      if @origin.hostile?(current_cell)
        found += 1
        break if found == 2
      end
    end
    result << current_cell
  end

  private

  def build_move(board, offset, steps)
    return @cells if @cells

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

  def capture?
    return unless defined?(@cells)

    @cells.any? { |cell| @origin.hostile?(cell) }
  end

  def friendly?
    return unless defined?(@cells)

    @cells.any? { |cell| @origin.friendly?(cell) }
  end

  def clear?
    return unless defined?(@cells)

    @cells.none? { |cell| @origin.friendly?(cell) || @origin.hostile?(cell) }
  end

  def path_clear
    return [] unless clear?

    result = []
    path = @cells.dup
    current_cell = path.shift
    until path.empty?
      result << current_cell
      current_cell = path.shift
    end
    result << current_cell
  end

  def path_obstructed
    return [] unless friendly? || capture?

    result = []
    path = @cells.dup
    current_cell = path.shift
    loop do
      result << current_cell if @origin.hostile?(current_cell)
      break if @origin.friendly?(current_cell) || @origin.hostile?(current_cell)

      result << current_cell
      current_cell = path.shift
    end
    result
  end

  def to_ary
    return unless defined?(@cells)

    @cells
  end

  alias to_a to_ary
end