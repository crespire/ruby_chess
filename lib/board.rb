# frozen_string_literal: true

# lib/board.rb

require_relative 'cell'

class Board
  attr_reader :data, :active, :castle, :passant, :half, :full

  def initialize
    @data = Array.new(8) { Array.new(8, nil) }
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
      end
      rank_ind += 1
    end

    true
  end

  def make_fen
    [pieces_to_fen, @active, @castle, @passant, @half, @full].join(' ')
  end

  def arr_to_std_chess(input)
    return nil unless input&.length == 2
    return nil unless input&.reduce(:+)&.between?(0, 14)

    letter = %w[a b c d e f g h]
    number = %w[8 7 6 5 4 3 2 1]

    alpha_i, num_i = input

    "#{letter[alpha_i]}#{number[num_i]}"
  end

  def std_chess_to_arr(input)
    coords = input.chars
    return nil unless coords.length == 2
    return nil unless ('a'..'h').include?(coords[0])
    return nil unless (1..8).include?(coords[1].to_i)

    lookup = Hash['a', 0, 'b', 1, 'c', 2, 'd', 3, 'e', 4, 'f', 5, 'g', 6, 'h', 7]

    [8 - coords[1].to_i, lookup[coords[0]]]
  end

  def cell(input)
    coords = std_chess_to_arr(input)
    return coords if coords.nil?

    @data[coords[0]][coords[1]]
  end

  private

  def pieces_to_fen
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
