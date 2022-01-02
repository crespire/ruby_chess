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
end
