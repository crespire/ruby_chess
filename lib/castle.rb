# frozen_string_literal: true

# lib/castle.rb

require_relative 'chess'
require_relative 'board'
require_relative 'cell'
require_relative 'checkmate'
require_relative 'piece'
require_relative 'movement'
require_relative 'pieces/all_pieces'

class Castle
  def initialize(game)
    @game = game
    @move_manager = game.move_manager
  end

  def update_rights(cell)
    piece = cell.piece
    return unless piece.is_a?(King) || piece.is_a?(Rook)

    rights = @game.castle.dup
    delete_rights = piece.white? ? 'KQ' : 'kq'
    if piece.is_a?(Rook)
      king_side = cell.name > 'e'
      king_side ? rights.delete!(delete_rights[0]) : rights.delete!(delete_rights[1])
    else
      rights.delete!(delete_rights)
    end
    rights = '-' if rights.empty?
    @game.castle = rights
  end

  ##
  # Returns additional moves if a castle is available
  def castle_moves(cell, king_moves)
    return [] unless cell.piece.is_a?(King)

    available = @game.castle.dup.chars
    available = (@game.active == 'w' ? available.grep(/[[:upper:]]/) : available.grep(/[[:lower:]]/)).join
    return [] if available.empty? || @game.checkmate.check?

    castleable = eligible_rooks(available)
    castleable.reject! { |check_cell| check_cell.piece.moved } # Just in case
    return [] if castleable.empty?

    available = filter_rook_rights(available, castleable, cell)
    return [] if available.empty?

    d_cell = cell.piece.white? ? @game.cell('d1') : @game.cell('d8')
    f_cell = cell.piece.white? ? @game.cell('f1') : @game.cell('f8')
    d_avail = king_moves.include?(d_cell.name)
    f_avail = king_moves.include?(f_cell.name)
    return [] unless d_avail || f_avail

    moves_map = {
      'q' => @game.cell('c8'),
      'k' => @game.cell('g8'),
      'Q' => @game.cell('c1'),
      'K' => @game.cell('g1')
    }

    cells_available = []
    available.each_char do |right|
      cell_to_add = moves_map[right]
      kingside = cell_to_add.name > 'e'
      safe = safe?(cell, cell_to_add)
      check_cell = kingside ? f_avail : d_avail
      cells_available << moves_map[right] if check_cell && safe
    end
    cells_available
  end

  def execute_castle(to)
    home_rank = @game.active == 'w' ? 1 : 8
    kingside = to.name > 'e'
    rook_location = kingside ? "h#{home_rank}" : "a#{home_rank}"
    rook_destination = kingside ? "f#{home_rank}" : "d#{home_rank}"
    rook_from = @game.cell(rook_location)
    rook_to = @game.cell(rook_destination)
    # Directly update the board to skip incrementing game stats
    @game.board.update_loc(rook_from, rook_to)
  end

  private

  def safe?(friendly_cell, cell)
    result = []
    @game.board.data.each do |rank|
      rank.each do |check_cell|
        next if check_cell.empty? || friendly_cell.friendly?(check_cell)

        piece = check_cell.piece
        enemy_moves = piece.moves(@game.board, check_cell.name)
        result << enemy_moves if enemy_moves.include?(cell)
      end
    end
    result.flatten.length.zero?
  end

  def eligible_rooks(available_rights)
    rook_cells = {
      'q' => @game.cell('a8'),
      'k' => @game.cell('h8'),
      'K' => @game.cell('h1'),
      'Q' => @game.cell('a1')
    }
    eligible = []
    available_rights.each_char { |side| eligible << rook_cells[side] unless rook_cells[side].nil? }
    eligible
  end

  def filter_rook_rights(available, castleable, king_cell)
    castleable.each do |rook_cell|
      moves = rook_cell.piece.valid_paths(@game.board, rook_cell)
      move = moves.select { |check_move| check_move.include?(king_cell) }.pop
      king_side = rook_cell.name > 'e'
      steps = move ? move.valid.length : 0
      clear = king_side ? steps == 2 : steps == 3
      delete = king_side ? 'K' : 'Q'
      delete = king_side ? 'k' : 'q' if king_cell.piece.black?
      available.delete!(delete) unless clear
    end
    available
  end
end
