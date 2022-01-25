# frozen_string_literal: true

# lib/chess.rb

require_relative 'board'
require_relative 'ui'

class Chess
  attr_accessor :board, :active, :castle, :passant, :half, :full, :ply

  def initialize(ui = UI.new(self))
    partial_fen = 'w KQkq - 0 1'
    parts = partial_fen.split(' ')

    @board = Board.new # Board defaults to starting position
    @active = parts[0]
    @castle = parts[1]
    @passant = parts[2]
    @half = parts[3].to_i
    @full = parts[4].to_i
    ply_offset = @active == 'b' ? 1 : 0
    @ply = @full + ply_offset
    @ui = ui
  end

  def set_board_state(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    parts = fen.split(' ')
    raise ArgumentError, "Invalid FEN provided, incorrect number of data segments: #{fen}" unless parts.length == 6

    pieces = parts[0]
    pieces_check = pieces.split('/').length
    raise ArgumentError, "Invalid FEN provided, found #{pieces_check} ranks." unless pieces_check == 8

    @active = parts[1]
    @castle = parts[2]
    @passant = parts[3]
    @half = parts[4].to_i
    @full = parts[5].to_i
    ply_offset = @active == 'b' ? 1 : 0
    @ply = @full + ply_offset
    @board = Board.new(pieces)
  end

  def make_fen
    [@board.to_fen, @active, @castle, @passant, @half, @full].join(' ')
  end

  def move_piece(origin, destination)
    return nil if origin.empty? || destination.empty?

    from = origin.is_a?(Cell) ? origin : cell(origin)
    to = destination.is_a?(Cell) ? destination : cell(destination)
    piece = from.piece.dup
    to_before = to.dup
    @board.update_loc(from, to)

    if piece.is_a?(Pawn)
      last_rank = destination.include?('1') || destination.include?('8')
      if last_rank
        pawn_promotion
      else
        pawn_passant(from, to)
      end
    end

    update_game_stats(piece, to_before)
  end

  def cell(piece, file_offset = 0, rank_offset = 0)
    @board.cell(piece, file_offset, rank_offset)
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
    @active = piece.white? ? 'b' : 'w'
  end

  def update_game_stats(piece, destination)
    update_active(piece)
    increment_ply
    if destination.empty?
      piece.is_a?(Pawn) ? reset_half : increment_half
    else
      destination.hostile?(piece) && !destination.empty? ? reset_half : increment_half
    end
    increment_full if piece.black?
  end

  def pawn_passant(from, to)
    rank_offset = @active == 'w' ? -1 : 1

    if @passant == to.name
      # Available and taken
      captured_cell = cell(to.name, 0, rank_offset)
      captured_cell.piece = nil
      @passant = '-'
    elsif @passant.length == 2 && to.name != @passant
      # Available, not taken: reset
      @passant = '-'
    end

    # Does this current move give a new passant?
    home_rank = from.name.include?('2') || from.name.include?('7')
    passant_rank = to.name.include?('4') || to.name.include?('5')
    return unless home_rank && passant_rank

    cell_east = cell(to.name, -1, 0)
    cell_west = cell(to.name, 1, 0)
    @passant = cell(to.name, 0, rank_offset).name if cell_east || cell_west
  end

  def pawn_promotion
    selection = @ui.prompt_pawn_promotion(@active)
    cell.piece = Piece::from_fen(selection)
  end
end