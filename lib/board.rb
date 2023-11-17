# frozen_string_literal: true

# lib/board.rb

require_relative 'cell'
require_relative 'chess'
require_relative 'piece'
require_relative 'pieces/all_pieces'

class Board
  attr_reader :data

  def initialize(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR')
    @data = Array.new(8) { Array.new(8, nil) }

    pieces = fen.split('/')
    col = ('a'..'h').to_a
    pieces.each_with_index do |rank, rank_ind|
      col_ind = 0
      rank.each_char do |char|
        case char
        when /[[:alpha:]]/
          piece = Piece::from_fen(char)
          @data[rank_ind][col_ind] = Cell.new("#{col[col_ind]}#{8 - rank_ind}", piece)
          col_ind += 1
        when /[[:digit:]]/
          times = char.to_i
          times.times do
            @data[rank_ind][col_ind] = Cell.new("#{col[col_ind]}#{8 - rank_ind}", nil)
            col_ind += 1
          end
        else
          raise ArgumentError, "Unexpected character in piece notation: #{char}"
        end
        raise ArgumentError, "Invalid FEN: Rank #{rank_ind + 1} does not have the correct amount of entries." unless @data[rank_ind].length == 8
      end
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
    return nil if origin.empty?

    from = origin.is_a?(Cell) ? origin : cell(origin)
    to = destination.is_a?(Cell) ? destination : cell(destination)
    to.piece = from.piece
    from.piece = nil
  end

  def cell(input, file_offset = 0, rank_offset = 0)
    coords = std_chess_to_arr(input)
    return nil if coords.nil?

    rank_ind = coords[0] + (rank_offset * -1)
    file_ind = coords[1] + file_offset
    return nil unless rank_ind.between?(0, 7)
    return nil unless file_ind.between?(0, 7)

    @data[rank_ind][file_ind]
  end

  def bking
    find_piece('k').pop
  end

  def wking
    find_piece('K').pop
  end

  def active_pieces
    count = 0
    @data.each do |rank|
      rank.each do |cell|
        next if cell.empty?

        count += 1
      end
    end
    count
  end

  def find_piece(fen)
    piece = fen.is_a?(Piece) ? fen : Piece.from_fen(fen)
    matches = []
    @data.each do |rank|
      rank.each do |cell|
        next if cell.empty?

        matches << cell if cell.piece == piece
      end
    end
    matches
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

  def to_ascii
    @data.each do |rank|
      rank.each { |cell| print cell.empty? ? '.' : cell.piece.fen }
      print "\n"
    end
  end
end
