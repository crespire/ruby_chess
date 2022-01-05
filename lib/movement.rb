# frozen_string_literal: true

# lib/movement.rb

class Movement
  def initialize(board = nil)
    @board = board
  end

  def valid_moves(cell)
  end

  def find_horizontal_moves(cell)
    offset = piece_offset(cell.content, 'h')

    east = path(cell, offset, 'e')
    west = path(cell, offset, 'w')

    (east + west).uniq.sort
  end

  def find_vertical_moves(cell)
    offset = piece_offset(cell.content, 'v')

    north = path(cell, offset, 'n')
    south = path(cell, offset, 's')

    (north + south).uniq.sort
  end

  def find_diagonal_moves(cell)
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

  def path(cell, offset, direction)
    result = []

    case direction
    when 'e', 'w'
      result = path_cardinal(cell, offset, direction)
    when 'n', 's'
      result = path_cardinal(cell, offset, direction)
    end
    result
  end

  def path_cardinal(cell, offset, direction)
    # std_chess_to_arr returns [rank, col] indicies
    # x dimension is rank, y dimention is col
    operation = %w[e s].include?(direction) ? proc { |change, i| change + i } : proc { |change, i| change - i }
    keep_rank = %w[e w].include?(direction)

    piece = cell.content
    rank, col = @board.std_chess_to_arr(cell.name)
    keep_ind = keep_rank ? rank : col
    change_ind = keep_rank ? col : rank

    result = []

    (1..offset).to_a.each do |i|
      new_ind = operation.call(change_ind, i)
      arr = keep_rank ? [keep_ind, new_ind] : [new_ind, keep_ind]
      step = @board.cell(@board.arr_to_std_chess(arr)) if (0..7).include?(new_ind)
      result << step.to_s if step && (step.empty? || step.capture?(piece))
      break unless step && step.empty? && step.capture?(piece)
    end

    result
  end

  def path_ordinal_main
    # std_chess_to_arr returns [rank, col] indicies.
  end

  def path_ordinal_alt
  end
end
