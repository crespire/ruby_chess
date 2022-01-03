# frozen_string_literal: true

# lib/movement.rb

class Movement
  def initialize(board = nil)
    @board = board
  end

  def horizontal_move(cell)
    result = []
    col_chrs = ('a'..'h').to_a
    piece = cell.content
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
      result << "#{col_chrs[right]}#{rank}" if (0..7).include?(right)
      result << "#{col_chrs[left]}#{rank}" if (0..7).include?(left)
    end

    result.sort
  end

  private

  def piece_offset(piece, direction)
    offsets = {
      'r': { 'h': 7, 'v': 7, 'd': 0, 'c': [0, 0] }
      'q': { 'h': 7, 'v': 7, 'd': 7, 'c': [0, 0] }
      'p': { 'h': 0, 'v': 1, 'd': 1, 'c': [2, 1] } # c for enpassant
      'b': { 'h': 0, 'v': 0, 'd': 7, 'c': [0, 0] }
      'k': { 'h': 1, 'v': 1, 'd': 1, 'c': [0, 0] }
      'n': { 'h': 0, 'v': 0. 'd': 0, 'c': [2, 1] } # c for Knight L
    }
  end
end