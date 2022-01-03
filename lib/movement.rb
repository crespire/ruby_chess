# frozen_string_literal: true

# lib/movement.rb

class Movement
  def initialize(board = nil)
    @board = board
  end

  def horizontal_move(cell)
    result = []
    col_chrs = ('a'..'h').to_a
    piece = cell.content.downcase
    coord = cell.name.chars
    rank = coord[1]
    map = Hash['a', 0, 'b', 1, 'c', 2, 'd', 3, 'e', 4, 'f', 5, 'g', 6, 'h', 7]
    offset = nil

    case piece
    when 'r', 'q'
      offset = 7
    when 'k'
      offset = 1
    end

    start = map[coord[0]]
    (1..offset).to_a.each do |i|
      right = start + i
      left = start - i
      result << "#{col_chrs[start + i]}#{rank}" if (1..8).include?(right)
      result << "#{col_chrs[start + i]}#{rank}" if (1..8).include?(left)
    end

    result.sort
  end
end