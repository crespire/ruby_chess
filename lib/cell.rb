#frozen_string_literal: true

# lib/cell.rb

class Cell
  attr_reader :content
  
  def initialize(piece = nil)
    @content = piece
  end

  def empty?
    @content.nil?
  end
end