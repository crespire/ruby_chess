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

  def to_fen
    @occupant.nil? ? 1 : @occupant
  end

  def to_display
    @occupant.nil? ? ' ' : @occupant
  end

  def to_s
    @name
  end

  def capture?(attacking)
    return nil if empty?

    atk_color = attacking.ord < 91 ? 'w' : 'b'
    color = @occupant.ord < 91 ? 'w' : 'b'
    atk_color != color
  end
end
