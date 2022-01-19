# frozen_string_literal: true

# lib/movement.rb

require_relative 'chess'

class Movement
  EMPTY_FEN = '8/8/8/8/8/8/8/8 w - - 1 2'

  def initialize(game)
    @board = game.board
    @game = game
  end

  def valid_moves(cell)
    return [] if cell.empty?

    case cell.occupant
    when 'k', 'K'
      # send message to castle manager to see if castle move is available
      find_king_moves(cell)
    else
      moves = find_all_moves(cell)
      king = cell.occupant.ord < 91 ? @board.cell(@board.wking) : @board.cell(@board.bking) # Find the friendly king
      enemy_attackers = attacks_on(king) # Identify direct attacks
      enemy_threats = threats_to(king) - attacks_on(king) # Identify threats
      # send message to castle manager if cell.occupant is a Rook to update status if required.
      return moves if enemy_attackers.empty? && enemy_threats.empty? # not in check

      enemy_attackers.each do |enemy_cell|
        direct_attack = vector(enemy_cell.name, king.name)
        interim = (direct_attack & moves).sort
        interim = interim.select { |move| move.start_with?('x') } if %w[n N].include?(enemy_cell.occupant)
        return interim if interim.length.positive? && enemy_threats.empty?

        return []
      end

      enemy_threats.each do |enemy_cell|
        threat = vector(enemy_cell.name, king.name)
        to_king = vector(cell.name, king.name)
        to_king.shift # get rid of the first element, which should be the current cell.
        full_path = (threat + to_king).uniq
        pinned = threat.include?(cell.name) || threat.include?("x#{cell.name}")

        coord1, coord2 = full_path.last(2)
        return moves if coord1.length < 3 || coord2.length < 3

        file_mag = (coord1[1].ord - coord2[1].ord).abs
        rank_mag = (coord1[2].ord - coord2[2].ord).abs
        adjacent = (file_mag <= 1) && (rank_mag <= 1)

        # If to_king length is 1 (king only) and we're not adjacent, there is an intervening piece
        pinned = false if to_king.length == 1 && !adjacent

        # Check if there are any intervening friendly pieces
        full_path.each do |coord|
          current = @board.cell(coord.gsub('x', ''))
          next if current.empty? || current.capture?(cell.occupant)
          next if current == cell || current == king

          pinned = false
        end
        return (pinned ? (threat & moves).sort : moves)
      end
    end
  end

  def find_all_moves(cell, board = @board)
    return [] if cell.empty?

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
    return [] if cell.empty?

    offset = piece_offset(cell.occupant, 'h')
    east = path(cell, offset, 'e', board)
    west = path(cell, offset, 'w', board)
    (east + west).uniq.sort
  end

  def find_vertical_moves(cell, board = @board)
    return [] if cell.empty?

    offset = piece_offset(cell.occupant, 'v')
    north = path(cell, offset, 'n', board)
    south = path(cell, offset, 's', board)
    (north + south).uniq.sort
  end

  def find_diagonal_moves(cell, board = @board)
    return [] if cell.empty?

    offset = piece_offset(cell.occupant, 'd')
    se = path(cell, offset, 'se', board)
    nw = path(cell, offset, 'nw', board)
    ne = path(cell, offset, 'ne', board)
    sw = path(cell, offset, 'sw', board)
    (se + nw + ne + sw).uniq.sort
  end

  def find_knight_moves(cell, board = @board)
    return [] if cell.empty?
    return [] unless %w[n N].include?(cell.occupant)

    n = knight(cell, 2, [-1, 1], board)
    e = knight(cell, [-1, 1], 2, board)
    s = knight(cell, -2, [-1, 1], board)
    w = knight(cell, [-1, 1], -2, board)

    (n + e + s + w).uniq.sort
  end

  def find_pawn_moves(cell, board = @board)
    return [] if cell.empty?
    return [] unless %w[p P].include?(cell.occupant)

    rank_dir = cell.occupant.ord < 91 ? -1 : 1 # Check color, if white, N, else S.
    start_rank_ind = rank_dir.negative? ? 6 : 1
    result = board.equal?(@board) ? pawn_moves(cell, rank_dir, start_rank_ind, board) : pawn_captures(cell, rank_dir, board)

    # Check for passant capture here and add it to the list if available.

    result.sort
  end

  def find_king_moves(cell, board = @board)
    return [] if cell.empty?
    return [] unless %w[k K].include?(cell.occupant)

    moves = find_all_moves(cell, board)
    threats = threat_map(cell).sort
    moves.reject { |move| threats.include?(move.gsub('x', '')) }
  end

  def threats_to(king_cell)
    return [] if king_cell.empty?

    empty_game = Chess.new
    threats = []
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || !king_cell.capture?(cell.occupant)

        empty_game.set_board_state(EMPTY_FEN)
        empty_board = empty_game.board
        current_threats = find_all_moves(cell, empty_board)
        current_threats.map! { |el| el.gsub('x', '') }
        threats << cell if current_threats.include?(king_cell.name)
      end
    end
    threats
  end

  def attacks_on(king_cell)
    attackers = []
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || !king_cell.capture?(cell.occupant)

        current_threats = find_all_moves(cell)
        current_threats.map! { |el| el.gsub('x', '') }
        attackers << cell if current_threats.include?(king_cell.name)
      end
    end
    attackers
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
      break unless step && step.empty?
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
      break unless step && step.empty?
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
    return [] if cell.empty?

    current_piece = cell.occupant
    empty_game = Chess.new
    threats = []
    @board.data.each do |rank|
      rank.each do |threat_cell|
        next if threat_cell.empty? || !threat_cell.capture?(current_piece)

        empty_game.set_board_state(EMPTY_FEN)
        empty_board = empty_game.board
        current_threats = find_all_moves(threat_cell, empty_board)
        threats = (threats + current_threats).uniq
      end
    end
    threats
  end

  def vector(start, finish)
    dir = vector_info(start, finish)
    result = path(@board.cell(start), 8, dir)
    result.unshift "x#{start}"
    result.push "x#{finish}"
  end

  def vector_info(start, finish)
    s_file = start.chars[0]
    s_rank = start.chars[1]
    f_file = finish.chars[0]
    f_rank = finish.chars[1]
    south = s_rank <=> f_rank
    east = s_file <=> f_file
    ns = { 1 => 's', 0 => '', -1 => 'n' }
    ew = { 1 => 'w', 0 => '', -1 => 'e' }
    dir = [ns[south], ew[east]].compact
    dir.join
  end
end
