# frozen_string_literal: true

# lib/cell.rb

require_relative 'piece'
require_relative 'pieces/all_pieces'

class Cell
  include Comparable
  attr_reader :name
  attr_accessor :piece

  def initialize(name = nil, piece = nil)
    @name = name
    @piece = piece
  end

  def empty?
    @piece.nil?
  end

  def full?
    !empty?
  end

  def hostile?(other)
    return nil if other.nil? || empty?
    return nil if other.is_a?(Cell) && other.empty?

    other = other.piece if other.is_a?(Cell)
    @piece.white? & other.black?
  end

  def friendly?(other)
    return nil if other.nil? || empty?

    !hostile?(other)
  end

  def to_fen
    @piece.nil? ? 1 : @piece.to_s
  end

  def to_display
    @piece.nil? ? ' ' : @piece.to_s
  end

  def to_s
    @name
  end

  def <=>(other)
    @name <=> other.name
  end
end
