# frozen_string_literal: true

# lib/cell.rb

class Cell
  attr_reader :name, :color, :content

  def initialize(name = nil, color = nil, piece = nil)
    @name = name
    @color = color
    @content = piece
  end

  def empty?
    @content.nil?
  end

  def to_fen
    @content.nil? ? 1 : @content
  end
end
