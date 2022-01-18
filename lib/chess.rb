# frozen_string_literal: true

# lib/chess.rb

require_relative 'board'

class Chess
  attr_accessor :active, :castle, :passant, :half, :full, :ply

  def initialize
    @board = Board.new
    @active = nil
    @castle = nil
    @passant = nil
    @half = nil
    @full = nil
    @ply = 0
  end

  def make_board(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
     # Make new board based on FEN
    parts = fen.split(' ')
    raise ArgumentError, "Invalid FEN provided, incorrect number of data segments: #{fen}" unless parts.length == 6

    pieces = parts[0].split('/')
    raise ArgumentError, "Invalid FEN provided, found #{pieces.length} ranks." unless pieces.length == 8

    @active = parts[1]
    @castle = parts[2]
    @passant = parts[3]
    @half = parts[4].to_i
    @full = parts[5].to_i
    @board = Board.new(pieces)
  end

  def make_fen
    pieces = @board.board_to_fen
    [pieces, @active, @castle, @passant, @half, @full].join(' ')
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