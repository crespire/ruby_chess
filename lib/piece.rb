# frozen_string_literal: true

# lib/piece.rb

class Piece
  include Comparable
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
      Piece.new(fen)
    end
  end

  def initialize(fen)
    @color = fen.ord < 91 ? 'w' : 'b'  
    @fen = fen
  end

  def white?
    @color == 'w'
  end

  def black?
    !white?
  end

  def to_s
    @fen
  end

  def <=>(other)
    @fen <=> other.fen
  end
end

class King < Piece
end

class Queen < Piece
end

class Bishop < Piece
end

class Rook < Piece
end

class Knight < Piece
end

class Pawn < Piece
end
