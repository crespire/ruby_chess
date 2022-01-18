# frozen_string_literal: true

# lib/chess.rb

require_relative 'board'

class Chess
  attr_accessor :active, :castle, :passant, :half, :full, :ply

  def initialize
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
  end

  def make_board(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
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

    from = @board.cell(origin)
    to = @board.cell(destination)
    update_game_stats(from.occupant, to.dup)
    @board.update_loc(from, to)
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
    if destination.empty? && @passant == '-'
      %w[p P].include?(piece) ? reset_half : increment_half
    elsif !@passant == '-' && (destination.name == @passant)
      reset_half
    else
      destination.capture?(piece) && !destination.empty? ? reset_half : increment_half
    end
    increment_full if piece.ord > 91
  end
end