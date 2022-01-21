# frozen_string_literal: true

# lib/piece.rb

#require_relative 'move'
#require_relative 'moves/all_moves'

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
    @color = fen.ord < 91 ? 'w' : 'b'
    @fen = fen
  end

  # Must be implemented by subclasses.
  def moves
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def white?
    @color == 'w'
  end

  def black?
    @color == 'b'
  end

  def to_s
    @fen
  end

  def ==(other)
    self.class == other.class && @color == other.color
  end
end
