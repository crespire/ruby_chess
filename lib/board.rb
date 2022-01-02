# frozen_string_literal: true

# lib/board.rb

require_relative 'cell'

class Board
  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
    @active = nil
    @castle = nil
    @passant = nil
    @half = nil
    @full = nil
  end

  def make_board(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    parts = fen.split(' ')
    raise ArgumentError, "Invalid FEN provided: #{fen}" unless parts.length == 6

    pieces = parts[0].split('/')
    @active = parts[1]
    @castle = parts[2]
    @passant = parts[3]
    @half = parts[4].to_i
    @full = parts[5].to_i

    rank_ind = 0
    col = ('a'..'h').to_a
    pieces.each do |rank|
      col_ind = 0
      rank.each_char do |piece|
        case piece
        when /[[:alpha:]]/
          @board[rank_ind][col_ind] = Cell.new("#{col[col_ind]}#{8 - rank_ind}", piece)
        when /[[:digit:]]/
          times = piece.to_i
          times.times do
            @board[rank_ind][col_ind] = Cell.new("#{col[col_ind]}#{8 - rank_ind}", nil)
            col_ind += 1
          end
          col_ind -= 1
        else
          raise ArgumentError, "Unexpected character in piece notation: #{piece}"
        end
        col_ind += 1
      end
      rank_ind += 1
    end
  end

  def make_fen
    [pieces_to_fen, @active, @castle, @passant, @half, @full].join(' ')
  end

  private

  def pieces_to_fen
    strs = []
    @board.each.with_index(1) do |rank, i|
      rank.each { |cell| strs << cell.to_fen }
      strs << '/' unless i == rank.length
    end
    parsed = []
    strs.chunk { |el| el.is_a?(String) }.each do |str, chunk|
      parsed << (str ? chunk.join : chunk.sum)
    end
    parsed.join
  end
end
