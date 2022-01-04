# frozen_string_literal: true

# lib/cell.rb

class Cell
  attr_reader :name, :content

  def initialize(name = nil, piece = nil)
    @name = name
    @content = piece
  end

  def empty?
    @content.nil?
  end

  def to_fen
    @content.nil? ? 1 : @content
  end

  def to_s
    @name
  end

  def capture?(attacking)
    return true if empty?

    atk_color = attacking.ord < 91 ? 'w' : 'b'
    color = @content.ord < 91 ? 'w' : 'b'
    atk_color != color
  end
end
