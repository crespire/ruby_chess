# frozen_string_literal: true

# lib/cell.rb

class Cell
  attr_reader :content, :name

  def initialize(piece = nil, name = nil)
    @name = name
    @content = piece
  end

  def empty?
    @content.nil?
  end

  def to_s
    @content.nil? ? 1 : @content
  end
end
