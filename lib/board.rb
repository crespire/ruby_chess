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
          @board[rank_ind][col_ind] = Cell.new(piece, "#{col[col_ind]}#{8 - rank_ind}")
        when /[[:digit:]]/
          times = piece.to_i
          times.times do
            @board[rank_ind][col_ind] = Cell.new(nil, "#{col[col_ind]}#{8 - rank_ind}")
            col_ind += 1
          end
          col_ind -= 1
        else
          raise ArgumentError, "Unexpected character in piece notation: #{pieces}"
        end
        col_ind += 1
      end
      rank_ind += 1
    end
  end

  def make_fen
    fen = []
    pieces = pieces_to_fen
    fen.push(pieces, @active, @castle, @passant, @half, @full)
    fen.join(' ')
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
      parsed << push = str ? chunk.join('') : chunk.sum
    end
    parsed.join('')
  end
end
