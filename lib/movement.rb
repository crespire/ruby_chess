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

  def find_moves(cell)
    return nil if cell.empty?

    case cell.occupant
    when 'p', 'P'
      find_pawn_moves(cell)
    when 'n', 'N'
      find_knight_moves(cell)
    when 'k', 'K'
      find_king_moves(cell)
    else
      vert = find_vertical_moves(cell)
      hori = find_horizontal_moves(cell)
      diag = find_diagonal_moves(cell)
      (vert + hori + diag).uniq.sort
    end
  end

  def find_knight_moves(cell)
    return nil if cell.empty?
    return nil unless %w[n N].include?(cell.occupant)

    n = knight(cell, 2, [-1, 1])
    e = knight(cell, [-1, 1], 2)
    s = knight(cell, -2, [-1, 1])
    w = knight(cell, [-1, 1], -2)

    (n + e + s + w).uniq.sort
  end

  def find_pawn_moves(cell)
    return nil if cell.empty?
    return nil unless %w[p P].include?(cell.occupant)

    rank_dir = cell.occupant.ord < 91 ? -1 : 1 # Check color, if white, N, else S.
    start_rank_ind = rank_dir.negative? ? 6 : 1
    result = pawn(cell, rank_dir, start_rank_ind)
    result.sort
  end

  def find_king_moves(cell)
    return nil if cell.empty?
    return nil unless %w[k K].include?(cell.occupant)

    vert = find_vertical_moves(cell)
    hori = find_horizontal_moves(cell)
    diag = find_diagonal_moves(cell)
    threats = threat_map(cell)

    ((vert + hori + diag).uniq - threats).sort
    # How do we handle cases where a king can capture a piece, but that move puts it in check?
    # I think we should compare all straight up moves, regardless of capture from the threat map.
    # After that, we can re-flag the captures the king can make.
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
    piece = cell.occupant

    next_refs = rank.is_a?(Array) ? [[start[0] + rank[0], start[1] + file], [start[0] + rank[1], start[1] + file]] : [[start[0] + rank, start[1] + file[0]],[start[0] + rank, start[1] + file[1]]]

    result = []
    next_refs.each do |arr|
      next if arr.any?(&:negative?)

      next_ref = @board.arr_to_std_chess(arr)
      step = @board.cell(next_ref) if next_ref
      cap = step.capture?(piece) && !step.empty? ? 'x' : '' if step
      result << (cap + step.to_s) if step && (step.empty? || step.capture?(piece))
    end

    result
  end

  def pawn(cell, rank_offset, home_rank)
    piece = cell.occupant

    start = @board.std_chess_to_arr(cell.name)
    double_fwd = start[0] == home_rank

    result = []
    next_refs = double_fwd ? [[start[0] + rank_offset, start[1]], [start[0] + (rank_offset * 2), start[1]]] : [[start[0] + rank_offset, start[1]]]
    next_refs.each do |arr|
      next if arr.any?(&:negative?)

      next_ref = @board.arr_to_std_chess(arr)
      step = @board.cell(next_ref) if next_ref
      result << step.to_s if step && step.empty?
      break unless step && step.empty?
    end

    # Check diagonals, only eligible if there is a capture available
    next_refs = [[start[0] + rank_offset, start[1] - 1], [start[0] + rank_offset, start[1] + 1]]
    next_refs.each do |arr|
      next if arr.any?(&:negative?)

      next_ref = @board.arr_to_std_chess(arr)
      step = @board.cell(next_ref) if next_ref
      cap = step.capture?(piece) && !step.empty? ? 'x' : '' if step
      result << (cap + step.to_s) if step && !step.empty? && step.capture?(piece)
    end

    result
  end

  def threat_map(cell)
    # current_piece = cell.occupant
    # threats = []
    # @board.each do |rank|
    #   rank.each do |threat_cell|
    #     next if threat_cell.empty? || !threat_cell.capture?(current_piece)
    #     current_threats = find_moves(threat_cell)
    #     current_threats.map { |name| name.gsub!('x', '') }
    #     threats = (threats + current_threats).uniq
    #   end
    # end
  end
end
