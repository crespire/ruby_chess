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
    @board = game.board
    @checkmate = Checkmate.new(game)
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
  def castle_moves(cell)
    return [] unless cell.piece.is_a?(King)
  
    available = @game.castle.dup
    available = (@game.active == 'w' ? available.chars.select { |char| char.ord < 91 } : available.chars.select { |char| char.ord > 91 }).join
    return [] if available.empty? || @checkmate.check?

    castleable = eligible_rooks(available)
    castleable.reject! { |cell| cell.piece.moved } # Just in case
    return [] if castleable.empty?

    available = filter_rook_rights(available, castleable, cell)
    return [] if available.empty?
    
    p @board
    king_moves = @game.move_manager.legal_moves(cell)
    d_cell = cell.piece.white? ? @game.cell('d1') : @game.cell('d8')
    f_cell = cell.piece.white? ? @game.cell('f1') : @game.cell('f8')
    return [] unless king_moves.include?(d_cell) || king_moves.include?(f_cell)

    moves_map = {
      'q' => @game.cell('c8'),
      'k' => @game.cell('g8'),
      'Q' => @game.cell('c1'),
      'K' => @game.cell('g1')
    }

    # IF we get king moves, and d isn't available, then c isn't available.
    # Same for f, then g.
    # If d is available, c is available if no attackers have c on their moves list.
    # If f is available, g is available if no attackers have g on their moves list.
    cells_available = []
    available.each_char do |right|
      cells_available << moves_map[right]
    end

    cells_available
  end

  private
  
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
      moves = rook_cell.piece.valid_paths(@board, rook_cell)
      move = moves.select { |move| move.include?(king_cell) }.pop
      king_side = rook_cell.name > 'e'
      steps = move ? move.valid.length : 0
      clear = king_side ? steps == 2 : steps == 3
      delete = king_side ? 'K' : 'Q'
      delete = king_side ? 'k' : 'q' if king_cell.piece.black?
      available.delete!(delete) if !clear
    end
    available
  end
end