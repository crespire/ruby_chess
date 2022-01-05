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
    offset = piece_offset(cell.content, 'd')

    se = path(cell, offset, 'se')
    nw = path(cell, offset, 'nw')
    ne = path(cell, offset, 'ne')
    sw = path(cell, offset, 'sw')

    (se + nw + ne + sw).uniq.sort
  end

  private

  def piece_offset(piece, direction)
    offsets = {
      'r' => { 'h' => 7, 'v' => 7, 'd' => 0, 'c' => 0 },
      'q' => { 'h' => 7, 'v' => 7, 'd' => 7, 'c' => 0 },
      'p' => { 'h' => 0, 'v' => 1, 'd' => 1, 'c' => 0 },
      'b' => { 'h' => 0, 'v' => 0, 'd' => 7, 'c' => 0 },
      'k' => { 'h' => 1, 'v' => 1, 'd' => 1, 'c' => 0 },
      'n' => { 'h' => 0, 'v' => 0, 'd' => 0, 'c' => [2, 1] } # c for Knight L
    }

    offsets[piece.downcase][direction]
  end

  def path(cell, offset, direction)
    result = []
    case direction
    when 'e', 'w', 'n', 's'
      result = path_cardinal(cell, offset, direction)
    when 'se', 'nw', 'ne', 'sw'
      result = path_ordinal(cell, offset, direction)
    end
    result
  end

  def path_cardinal(cell, offset, direction)
    return [] if offset.zero?

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
      step = @board.cell(@board.arr_to_std_chess(arr)) if new_ind.between?(0, 7)
      result << step.to_s if step && (step.empty? || step.capture?(piece))
      break unless step && step.empty? && step.capture?(piece)
    end
    result
  end

  def path_ordinal(cell, offset, direction)
    return [] if offset.zero?
    # std_chess_to_arr returns [rank, col] indicies
    # x dimension is rank, y dimention is col

    operation = ordinal_proc(direction)
    piece = cell.content
    rank_ind, col_ind = @board.std_chess_to_arr(cell.name)

    result = []
    (1..offset).to_a.each do |i|
      next_ind = operation.call(rank_ind, col_ind, i)
      next if next_ind.any?(&:negative?)

      next_ref = @board.arr_to_std_chess(next_ind)
      step = @board.cell(next_ref) if next_ref
      result << step.to_s if step && (step.empty? || step.capture?(piece))
      break unless step && step.empty? && step.capture?(piece)
    end
    result
  end

  def ordinal_proc(direction)
    case direction
    when 'se'
      proc { |x, y, i| [x + i, y + i] }
    when 'nw'
      proc { |x, y, i| [x - i, y - i] }
    when 'ne'
      proc { |x, y, i| [x - i, y + i] }
    when 'sw'
      proc { |x, y, i| [x + i, y - i] }
    end
  end
end
