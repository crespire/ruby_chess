# frozen_string_literal: true

# lib/board.rb

require_relative 'cell'
require_relative 'chess'

class Board
  attr_reader :data, :game

  def initialize(pieces = ['rnbqkbnr', 'pppppppp', '8', '8', '8', '8', 'PPPPPPPP', 'RNBQKBNR'])
    @data = Array.new(8) { Array.new(8, nil) }
    rank_ind = 0
    col = ('a'..'h').to_a
    pieces.each do |rank|
      col_ind = 0
      rank.each_char do |piece|
        case piece
        when /[[:alpha:]]/
          @data[rank_ind][col_ind] = Cell.new("#{col[col_ind]}#{8 - rank_ind}", piece)
        when /[[:digit:]]/
          times = piece.to_i
          times.times do
            @data[rank_ind][col_ind] = Cell.new("#{col[col_ind]}#{8 - rank_ind}", nil)
            col_ind += 1
          end
          col_ind -= 1
        else
          raise ArgumentError, "Unexpected character in piece notation: #{piece}"
        end
        col_ind += 1
        raise ArgumentError, "Invalid FEN: Rank #{rank_ind + 1} does not have the correct amount of entries." unless @data[rank_ind].length == 8
      end
      rank_ind += 1
    end
  end

  def arr_to_std_chess(input)
    return nil unless input.length == 2
    return nil unless input.all? { |i| i.between?(0, 7) }

    letter = %w[a b c d e f g h]
    rank, col = input
    "#{letter[col]}#{8 - rank}"
  end

  def std_chess_to_arr(input)
    coords = input.chars
    return nil unless coords.length == 2
    return nil unless ('a'..'h').include?(coords[0])
    return nil unless (1..8).include?(coords[1].to_i)

    lookup = Hash['a', 0, 'b', 1, 'c', 2, 'd', 3, 'e', 4, 'f', 5, 'g', 6, 'h', 7]
    [8 - coords[1].to_i, lookup[coords[0]]]
  end

  def update_loc(origin, destination)
    return nil if origin.empty? || destination.empty?

    from = cell(origin)
    to = cell(destination)
    to.occupant = from.occupant.dup
    from.occupant = nil
  end

  def cell(input)
    coords = std_chess_to_arr(input)
    return nil if coords.nil?

    @data[coords[0]][coords[1]]
  end

  def bking
    find_piece('k').pop
  end

  def wking
    find_piece('K').pop
  end

  def find_piece(piece)
    coords = []
    cols = ('a'..'h').to_a
    @data.each.with_index(1) do |rank, rank_ind|
      rank.each_with_index do |cell, file_ind|
        coords << "#{cols[file_ind]}#{9 - rank_ind}" if piece == cell.occupant
      end
    end
    coords.sort
  end

  def to_fen
    strs = []
    @data.each.with_index(1) do |rank, i|
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
