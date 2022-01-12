# frozen_string_literal: true

# lib/movement.rb

class Movement
  attr_reader :passant_capture
  attr_accessor :bking, :wking

  EMPTY_FEN = '8/8/8/8/8/8/8/8 w - - 1 2'

  def initialize(board = nil)
    @board = board
    @passant_capture = nil
    @bking = 'e8'
    @wking = 'e1'
  end

  def valid_moves(cell)
    return nil if cell.empty?

    case cell.occupant
    when 'k', 'K'
      find_king_moves(cell)
    else
      moves = find_all_moves(cell)
      king = cell.occupant.ord < 91 ? @wking : @bking # Find the friendly king
      nme_atkrs = can_attack_king(@board.cell(king)) # Identify pieces that could attack the friendly
      return moves if nme_atkrs.empty?

      results = []
      nme_atkrs.each do |nme_cell|
        # Find the path from the attacker's current cell to the king, mark all captures (regardless of side).
        # This path should include all squares to the king.
        # If there are two captures, with the last capture being the king, this friendly piece is pinned.
        # When pinned, valid moves are the intersctions of moves and nme vector; otherwise,
        # there are no available moves without putting king in check.
        # If there are more than two captures, then this piece can move freely.
        nme_vector = vector(nme_cell.name, king)
        last3 = nme_vector.last(3)
        captures = last3.count { |el| el.start_with?('x') }
        results = captures > 2 ? moves : (nme_vector & moves).sort
      end
      results.sort
    end
  end

  def find_all_moves(cell, board = @board)
    return nil if cell.empty?

    case cell.occupant
    when 'p', 'P'
      find_pawn_moves(cell, board)
    when 'n', 'N'
      find_knight_moves(cell, board)
    else
      vert = find_vertical_moves(cell, board)
      hori = find_horizontal_moves(cell, board)
      diag = find_diagonal_moves(cell, board)
      (vert + hori + diag).uniq.sort
    end
  end

  def find_horizontal_moves(cell, board = @board)
    return nil if cell.empty?

    offset = piece_offset(cell.occupant, 'h')
    east = path(cell, offset, 'e', board)
    west = path(cell, offset, 'w', board)
    (east + west).uniq.sort
  end

  def find_vertical_moves(cell, board = @board)
    return nil if cell.empty?

    offset = piece_offset(cell.occupant, 'v')
    north = path(cell, offset, 'n', board)
    south = path(cell, offset, 's', board)
    (north + south).uniq.sort
  end

  def find_diagonal_moves(cell, board = @board)
    return nil if cell.empty?

    offset = piece_offset(cell.occupant, 'd')
    se = path(cell, offset, 'se', board)
    nw = path(cell, offset, 'nw', board)
    ne = path(cell, offset, 'ne', board)
    sw = path(cell, offset, 'sw', board)
    (se + nw + ne + sw).uniq.sort
  end

  def find_knight_moves(cell, board = @board)
    return nil if cell.empty?
    return nil unless %w[n N].include?(cell.occupant)

    n = knight(cell, 2, [-1, 1], board)
    e = knight(cell, [-1, 1], 2, board)
    s = knight(cell, -2, [-1, 1], board)
    w = knight(cell, [-1, 1], -2, board)

    (n + e + s + w).uniq.sort
  end

  def find_pawn_moves(cell, board = @board)
    return nil if cell.empty?
    return nil unless %w[p P].include?(cell.occupant)

    gen_moves = board.equal?(@board)
    rank_dir = cell.occupant.ord < 91 ? -1 : 1 # Check color, if white, N, else S.
    start_rank_ind = rank_dir.negative? ? 6 : 1
    result = gen_moves ? pawn_moves(cell, rank_dir, start_rank_ind, board) : pawn_captures(cell, rank_dir, board)
    result.sort
  end

  def find_king_moves(cell, board = @board)
    return nil if cell.empty?
    return nil unless %w[k K].include?(cell.occupant)

    moves = find_all_moves(cell, board)
    threats = threat_map(cell)
    moves.reject! { |move| threats.include?(move.gsub('x', '')) }
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

  def path(cell, offset, direction, board = @board)
    result = []
    case direction
    when 'e', 'w', 'n', 's'
      result = path_cardinal(cell, offset, direction, board)
    when 'se', 'nw', 'ne', 'sw'
      result = path_ordinal(cell, offset, direction, board)
    end
    result
  end

  def path_cardinal(cell, offset, direction, board = @board)
    return [] if offset.zero?

    operation = %w[e s].include?(direction) ? proc { |change, i| change + i } : proc { |change, i| change - i }
    keep_rank = %w[e w].include?(direction)
    piece = cell.occupant
    rank, file = board.std_chess_to_arr(cell.name)
    keep_ind = keep_rank ? rank : file
    change_ind = keep_rank ? file : rank

    result = []

    (1..offset).to_a.each do |i|
      new_ind = operation.call(change_ind, i)
      arr = keep_rank ? [keep_ind, new_ind] : [new_ind, keep_ind]
      step = board.cell(board.arr_to_std_chess(arr)) if new_ind.between?(0, 7)
      cap = step.capture?(piece) && !step.empty? ? 'x' : '' if step
      result << (cap + step.to_s) if step && (step.empty? || step.capture?(piece))
      break unless step && step.empty? && !step.capture?(piece)
    end
    result
  end

  def path_ordinal(cell, offset, direction, board = @board)
    return [] if offset.zero?

    operation = ordinal_proc(direction)
    piece = cell.occupant
    rank_ind, file_ind = board.std_chess_to_arr(cell.name)

    result = []
    (1..offset).to_a.each do |i|
      next_ind = operation.call(rank_ind, file_ind, i)
      next if next_ind.any?(&:negative?)

      next_ref = board.arr_to_std_chess(next_ind)
      step = board.cell(next_ref) if next_ref
      cap = step.capture?(piece) && !step.empty? ? 'x' : '' if step
      result << (cap + step.to_s) if step && (step.empty? || step.capture?(piece))
      break unless step && step.empty? && !step.capture?(piece)
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

  def knight(cell, rank, file, board = @board)
    start = board.std_chess_to_arr(cell.name)
    piece = cell.occupant
    next_refs = rank.is_a?(Array) ? [[start[0] + rank[0], start[1] + file], [start[0] + rank[1], start[1] + file]] : [[start[0] + rank, start[1] + file[0]],[start[0] + rank, start[1] + file[1]]]
    result = []
    next_refs.each do |arr|
      next if arr.any?(&:negative?)

      next_ref = board.arr_to_std_chess(arr)
      step = board.cell(next_ref) if next_ref
      cap = step.capture?(piece) && !step.empty? ? 'x' : '' if step
      result << (cap + step.to_s) if step && (step.empty? || step.capture?(piece))
    end

    result
  end

  def pawn_moves(cell, rank_offset, home_rank, board = @board)
    piece = cell.occupant
    start = board.std_chess_to_arr(cell.name)
    double_fwd = start[0] == home_rank
    result = []
    next_refs = double_fwd ? [[start[0] + rank_offset, start[1]], [start[0] + (rank_offset * 2), start[1]]] : [[start[0] + rank_offset, start[1]]]
    next_refs.each do |arr|
      next if arr.any?(&:negative?)

      next_ref = board.arr_to_std_chess(arr)
      step = board.cell(next_ref) if next_ref
      result << step.to_s if step && step.empty?
      break unless step && step.empty?
    end

    @passant_capture = result[0] if double_fwd

    # Check diagonals, only eligible if there is a capture available
    next_refs = [[start[0] + rank_offset, start[1] - 1], [start[0] + rank_offset, start[1] + 1]]
    next_refs.each do |arr|
      next if arr.any?(&:negative?)

      next_ref = board.arr_to_std_chess(arr)
      step = board.cell(next_ref) if next_ref
      cap = step.capture?(piece) && !step.empty? ? 'x' : '' if step
      result << (cap + step.to_s) if step && !step.empty? && step.capture?(piece)
    end

    result
  end

  def pawn_captures(cell, rank_offset, board = @board)
    start = board.std_chess_to_arr(cell.name)
    result = []
    next_refs = [[start[0] + rank_offset, start[1] - 1], [start[0] + rank_offset, start[1] + 1]]
    next_refs.each do |arr|
      next if arr.any?(&:negative?)

      next_ref = board.arr_to_std_chess(arr)
      step = board.cell(next_ref) if next_ref
      result << step.to_s if step
    end
    result
  end

  def threat_map(cell)
    return [] if cell.occupant.nil?

    current_piece = cell.occupant
    empty_board = Board.new
    threats = []
    @board.data.each do |rank|
      rank.each do |threat_cell|
        next if threat_cell.empty? || !threat_cell.capture?(current_piece)

        empty_board.make_board(EMPTY_FEN)
        current_threats = find_all_moves(threat_cell, empty_board)
        threats = (threats + current_threats).uniq
      end
    end
    threats
  end

  def can_attack_king(king_cell)
    return [] if king_cell.empty?

    empty_board = Board.new
    threats = []
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || !king_cell.capture?(cell.occupant)

        empty_board.make_board(EMPTY_FEN)
        current_threats = find_all_moves(cell, empty_board)
        current_threats.map! { |el| el.gsub('x', '') }
        threats << cell if current_threats.include?(king_cell.name)
      end
    end
    threats
  end

  def vector(start, finish)
    dir = vector_info(start, finish)
    offset = 7
    # Following the rules for the piece, travel to the king.
    result = path(@board.cell(start), offset, dir)
    # Return list of moves, including the start and finish as captures
    # We add the captures because the start should be a valid capture for the piece we're moving
    # The last capture should be the king capture from the enemy piece.
    result.unshift "x#{start}"
    result << "x#{finish}"
  end

  def vector_info(start, finish)
    s_letter = start.chars[0]
    s_number = start.chars[1]
    f_letter = finish.chars[0]
    f_number = finish.chars[1]
    south = s_number <=> f_number
    east = s_letter <=> f_letter
    ns = { 1 => 's', 0 => '', -1 => 'n' }
    ew = { 1 => 'w', 0 => '', -1 => 'e' }
    dir = [ns[south], ew[east]].compact
    dir.join
  end
end
