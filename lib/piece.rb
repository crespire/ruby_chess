# frozen_string_literal: true

# lib/piece.rb

require_relative 'move'

class Piece
  attr_reader :color, :fen

  def self.from_fen(fen)
    case fen.downcase
    when 'p'
      Pawn.new(fen)
    when 'k'
      King.new(fen)
    when 'b'
      Bishop.new(fen)
    when 'r'
      Rook.new(fen)
    when 'q'
      Queen.new(fen)
    when 'n'
      Knight.new(fen)
    else
      raise ArgumentError, "Unrecognized FEN character '#{fen}'"
    end
  end

  def initialize(fen)
    @color = fen.ord < 91 ? :white : :black
    @fen = fen
  end

  ##
  # Returns a list of all Move objects, regardless of their status.
  def all_paths
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  ##
  # Returns a list of Move objects that are not dead.
  def valid_paths
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  ##
  # Returns a list of Cell objects that are valid destinations.
  def moves
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def captures(board, origin)
    all_paths(board, origin)
  end

  def slides?
    false
  end

  def white?
    @color == :white
  end

  def black?
    @color == :black
  end

  def to_s
    @fen
  end

  def ==(other)
    self.class == other.class && @color == other.color
  end
end
