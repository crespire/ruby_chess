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

    from = cell(origin)
    to = cell(destination)
    piece = from.occupant.dup
    to_before = to.dup
    @board.update_loc(from, to)

    # Do I have enough information here to make en passant updates?

    last_rank = to.name.include?('1') || to.name.include?('8')
    pawn_promotion(@active) if last_rank && %w[p P].include?(to.occupant)
    update_game_stats(piece, to_before)
  end

  def cell(piece)
    @board.cell(piece)
  end

  def pawn_promotion(active)
    selection = @ui.prompt_pawn_promotion
    cell.occupant
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
    @active = piece.ord < 91 ? 'b' : 'w'
  end

  def update_game_stats(piece, destination)
    update_active(piece)
    increment_ply
    if destination.empty?
      %w[p P].include?(piece) ? reset_half : increment_half
    else
      destination.capture?(piece) && !destination.empty? ? reset_half : increment_half
    end
    increment_full if piece.ord > 91
  end
end