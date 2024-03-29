# frozen_string_literal: true

# lib/chess.rb

require_relative 'ui'
require_relative 'board'
require_relative 'castle'
require_relative 'movement'
require_relative 'checkmate'
require_relative 'save'

class Chess
  attr_accessor :active, :castle, :passant, :half, :full, :ply, :fen_history
  attr_reader :board, :move_manager, :castle_manager, :checkmate_manager

  def initialize(ui = UI.new(self))
    partial_fen = 'w KQkq - 0 1'
    parts = partial_fen.split(' ')

    @board = Board.new # Board defaults to starting position
    @active = parts[0] == 'w' ? :white : :black
    @castle = parts[1]
    @passant = parts[2]
    @half = parts[3].to_i
    @full = parts[4].to_i
    ply_offset = @active == :black ? 1 : 0
    @ply = @full + ply_offset
    @ui = ui
    @move_manager = MovementManager.new(self)
    @castle_manager = CastleManager.new(self)
    @checkmate_manager = CheckmateManager.new(self)
    @fen_history = []
  end

  def set_board_state(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    parts = fen.split(' ')
    raise ArgumentError, "Invalid FEN provided, incorrect number of data segments: #{fen}" unless parts.length == 6

    pieces = parts[0]
    pieces_check = pieces.split('/').length
    raise ArgumentError, "Invalid FEN provided, found #{pieces_check} ranks." unless pieces_check == 8

    @active = parts[1] == 'w' ? :white : :black
    @castle = parts[2]
    @passant = parts[3]
    @half = parts[4].to_i
    @full = parts[5].to_i
    ply_offset = @active == :black ? 1 : 0
    @ply = @full + ply_offset
    @board = Board.new(pieces)
    @fen_history = [fen.split('-')[0].strip!]
  end

  def make_fen
    [@board.to_fen, (@active == :white ? 'w' : 'b'), @castle, @passant, @half, @full].join(' ')
  end

  def move_piece(origin, destination)
    return nil if origin.empty?

    from = origin.is_a?(Cell) ? origin : cell(origin)
    to = destination.is_a?(Cell) ? destination : cell(destination)
    piece = from.piece.dup
    to_before = to.dup
    @castle_manager.execute_castle(to) if piece.is_a?(King) && castling_move?(from, to)
    @board.update_loc(from, to)
    @castle_manager.update_rights(to)

    pawn_helper(from, to) if piece.is_a?(Pawn)
    piece.moved = true if piece.is_a?(King) || piece.is_a?(Rook)

    update_game_stats(piece, to_before)
    @fen_history << make_fen.split('-')[0].strip!
  end

  def cell(piece, file_offset = 0, rank_offset = 0)
    @board.cell(piece, file_offset, rank_offset)
  end

  def play
    @ui.show_welcome
    load_save = @ui.prompt_save == 'load'
    load if load_save
    @ui.prompt_continue
    until @checkmate_manager.gameover?
      destination = nil
      while destination.nil?
        @ui.clear_console
        @ui.show_board
        selection = @ui.prompt_pick_piece
        unless selection.is_a?(Cell)
          save if selection == 'save'
          abort('Thanks for playing!') if selection == 'exit'
        end
        legal_moves = @move_manager.legal_moves(selection)
        @ui.clear_console
        @ui.show_board(legal_moves)
        destination = @ui.prompt_pick_move(selection, legal_moves)
      end
      move_piece(selection, destination)
      @ui.clear_console
    end
    losing_king = @active == :white ? @board.wking : @board.bking
    losing_king = [] unless @checkmate_manager.checkmate?
    @ui.show_board(losing_king)
    @ui.show_gameover
    ans = @ui.prompt_play_again
    if %w[y Y].include?(ans)
      set_board_state
      play
    else
      abort('Thanks for playing!')
    end
  end

  def save
    Save.save_to_file('save/fen.txt', make_fen)
    abort('Thanks for playing!')
  end

  def load
    fen = Save.load_from_file('save/fen.txt')
    @ui.show_fen(fen)
    return if fen.nil?

    set_board_state(fen)
  end

  def active_king
    @active == :white ? @board.wking : @board.bking
  end

  private

  def increment_full
    @full += 1
  end

  def increment_ply
    @ply += 1
  end

  def increment_half
    @half += 1
  end

  def reset_half
    @half = 0
  end

  def update_active(piece)
    @active = piece.white? ? :black : :white
  end

  def update_game_stats(piece, destination)
    update_active(piece)
    increment_ply
    if destination.empty?
      piece.is_a?(Pawn) ? reset_half : increment_half
    else
      destination.hostile?(piece) ? reset_half : increment_half
    end
    increment_full if piece.black?
  end

  def pawn_helper(from, to)
    last_rank = to.include?('1') || to.include?('8')
    if last_rank
      pawn_promotion(to)
    else
      pawn_passant(from, to)
    end
  end

  def pawn_passant(from, to)
    rank_offset = @active == :white ? -1 : 1

    if @passant == to.name
      captured_cell = cell(to.name, 0, rank_offset)
      captured_cell.piece = nil
      @passant = '-'
    elsif @passant != '-' && to.name != @passant
      @passant = '-'
    end

    home_rank = from.name.include?('2') || from.name.include?('7')
    passant_rank = to.name.include?('4') || to.name.include?('5')
    return unless home_rank && passant_rank

    cell_east = cell(to.name, -1, 0)
    cell_west = cell(to.name, 1, 0)
    @passant = cell(to.name, 0, rank_offset).name if cell_east || cell_west
  end

  def pawn_promotion(cell)
    selection = @ui.prompt_pawn_promotion(cell)
    cell.piece = Piece.from_fen(selection)
  end

  def castling_move?(from, to)
    cell1_file = from.name.chars[0]
    cell2_file = to.name.chars[0]

    range = cell1_file < cell2_file ? (cell1_file...cell2_file) : (cell2_file...cell1_file)

    range.to_a.length > 1
  end
end
