# frozen_string_literal: true

# lib/cell.rb

class Cell
  attr_reader :name
  attr_accessor :occupant

  def initialize(name = nil, piece = nil)
    @name = name
    @occupant = piece
  end

  def empty?
    @occupant.nil?
  end

  def full?
    !empty?
  end

  def hostile?(other)
    return nil if other.nil? || empty?
    return nil if other.is_a?(Cell) && other.empty?

    other = other.occupant if other.is_a?(Cell)

    atk_color = other.ord < 91 ? 'w' : 'b'
    color = @occupant.ord < 91 ? 'w' : 'b'
    atk_color != color
  end

  def friendly?(other)
    return nil if other.nil?
    return nil if empty?

    !hostile?(other)
  end

  def to_fen
    @occupant.nil? ? 1 : @occupant.to_s
  end

  def to_display
    @occupant.nil? ? ' ' : @occupant.to_s
  end

  def to_s
    @name
  end
end
