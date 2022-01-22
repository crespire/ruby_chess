# frozen_string_literal: true

# lib/move.rb
require 'forwardable'

class Move
  include Enumerable
  extend Forwardable

  def_delegators :@cells, :<<, :&, :length, :each, :union, :uniq
  attr_reader :cells

  def initialize(board, origin, offset, steps = 1)
    @origin = origin.is_a?(Cell) ? origin : board.cell(origin)
    @cells ||= cells(board, offset, steps)
  end

  def dead?
    @cells.empty?
  end

  def to_ary
    return unless defined?(@cells)

    @cells
  end

  alias to_a to_ary

  def capture?
    return unless defined?(@cells)

    @cells.any? { |cell| @origin.hostile?(cell) }
  end

  def friendly?
    return unless defined?(@cells)

    @cells.any? { |cell| @origin.friendly?(cell) }
  end

  def path_to_enemy; end

  def path_to_friendly; end

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