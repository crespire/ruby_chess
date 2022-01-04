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
    offset = piece_offset(piece, 'h')

    start = map[coord[0]]
    (1..offset).to_a.each do |i|
      right_ind = start + i
      left_ind = start - i
      right = (0..7).include?(right_ind) ? @board.cell("#{col_chrs[right_ind]}#{rank}") : false
      left = (0..7).include?(left_ind) ? @board.cell("#{col_chrs[left_ind]}#{rank}") : false
      result << right.to_s if right && (right.empty? || right.capture?(piece))
      result << left.to_s if left && (left.empty? || left.capture?(piece))
    end

    result.sort
  end

  private

  def piece_offset(piece, direction)
    offsets = {
      'r' => { 'h' => 7,   'v' => 7,   'd' => nil, 'c' => nil },
      'q' => { 'h' => 7,   'v' => 7,   'd' => 7,   'c' => nil },
      'p' => { 'h' => nil, 'v' => 1,   'd' => 1,   'c' => nil },
      'b' => { 'h' => nil, 'v' => nil, 'd' => 7,   'c' => nil },
      'k' => { 'h' => 1,   'v' => 1,   'd' => 1,   'c' => nil },
      'n' => { 'h' => nil, 'v' => nil, 'd' => nil, 'c' => [2, 1] } # c for Knight L
    }

    offsets[piece.downcase][direction]
  end
end
