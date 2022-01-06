# frozen_string_literal: true

# lib/movement.rb

class Movement
  def initialize(board = nil)
    @board = board
  end

  def valid_moves(cell)
  end

  def find_horizontal_moves(cell)
    return nil if cell.empty?

    offset = piece_offset(cell.occupant, 'h')
    east = path(cell, offset, 'e')
    west = path(cell, offset, 'w')
    (east + west).uniq.sort
  end

  def find_vertical_moves(cell)
    return nil if cell.empty?

    offset = piece_offset(cell.occupant, 'v')
    north = path(cell, offset, 'n')
    south = path(cell, offset, 's')
    (north + south).uniq.sort
  end

  def find_diagonal_moves(cell)
    return nil if cell.empty?

    offset = piece_offset(cell.occupant, 'd')
    se = path(cell, offset, 'se')
    nw = path(cell, offset, 'nw')
    ne = path(cell, offset, 'ne')
    sw = path(cell, offset, 'sw')
    (se + nw + ne + sw).uniq.sort
  end

  def find_knight_moves(cell)
    return nil unless %w[n N].include?(cell.occupant)

    n = knight(cell, 2, [-1, 1])
    e = knight(cell, [-1, 1], 2)
    s = knight(cell, -2, [-1, 1])
    w = knight(cell, [-1, 1], -2)

    (n + e + s + w).uniq.sort
  end

  private

  def piece_offset(piece, direction)
    offsets = {
      'r' => { 'h' => 7, 'v' => 7, 'd' => 0 },
      'q' => { 'h' => 7, 'v' => 7, 'd' => 7 },
      'p' => { 'h' => 0, 'v' => 1, 'd' => 1 },
      'b' => { 'h' => 0, 'v' => 0, 'd' => 7 },
      'k' => { 'h' => 1, 'v' => 1, 'd' => 1 },
      'n' => { 'h' => 0, 'v' => 0, 'd' => 0 }
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

    operation = %w[e s].include?(direction) ? proc { |change, i| change + i } : proc { |change, i| change - i }
    keep_rank = %w[e w].include?(direction)
    piece = cell.occupant
    rank, file = @board.std_chess_to_arr(cell.name)
    keep_ind = keep_rank ? rank : file
    change_ind = keep_rank ? file : rank

    result = []

    (1..offset).to_a.each do |i|
      new_ind = operation.call(change_ind, i)
      arr = keep_rank ? [keep_ind, new_ind] : [new_ind, keep_ind]
      step = @board.cell(@board.arr_to_std_chess(arr)) if new_ind.between?(0, 7)
      cap = step.capture?(piece) && !step.empty? ? 'x' : '' if step
      result << (cap + step.to_s) if step && (step.empty? || step.capture?(piece))
      break unless step && step.empty? && step.capture?(piece)
    end
    result
  end

  def path_ordinal(cell, offset, direction)
    return [] if offset.zero?

    operation = ordinal_proc(direction)
    piece = cell.occupant
    rank_ind, file_ind = @board.std_chess_to_arr(cell.name)

    result = []
    (1..offset).to_a.each do |i|
      next_ind = operation.call(rank_ind, file_ind, i)
      next if next_ind.any?(&:negative?)

      next_ref = @board.arr_to_std_chess(next_ind)
      step = @board.cell(next_ref) if next_ref
      cap = step.capture?(piece) && !step.empty? ? 'x' : '' if step
      result << (cap + step.to_s) if step && (step.empty? || step.capture?(piece))
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

  def knight(cell, rank, file)
    start = @board.std_chess_to_arr(cell.name)

    if rank.is_a?(Array)
      next_refs = [
        [start[1] + rank[0], start[0] + file],
        [start[1] + rank[1], start[0] + file]
        ]
    else
      next_refs = [
        [start[1] + rank, start[0] + file[0]],
        [start[1] + rank, start[0] + file[1]]
      ]
    end

    result = []
    next_refs.each do |arr|
      next if arr.any?(&:negative?)

      next_ref = @board.arr_to_std_chess(arr)
      step = @board.cell(next_ref) if next_ref
      cap = step.capture?(piece) && !step.empty? ? 'x' : '' if step
      result << (cap + step.to_s) if step && (step.empty? || step.capture?(piece))
      break unless step && step.empty? && step.capture?(piece)
    end

    result
  end
end
