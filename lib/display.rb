# frozen_string_literal: true

# lib/movement.rb

class Display
  PIECE_LOOKUP = {
    'P' => '♟︎',
    'R' => '♜',
    'N' => '♞',
    'B' => '♝',
    'Q' => '♛',
    'K' => '♚',
    'p' => '♙',
    'r' => '♖',
    'n' => '♘',
    'b' => '♗',
    'q' => '♕',
    'k' => '♔',
    ' ' => ' '
  }.freeze

  def initialize(board = nil)
    @board = board
  end

  def show_board(board = @board)
    display_track = 0
    cols = ('a'..'h').to_a
    print '  '
    cols.each { |char| print " #{char} " }
    print "\n"

    rank_ind = 8
    board.data.each do |rank|
      print "#{rank_ind} "
      rank.each do |cell|
        print colorize_cell_bg(" #{PIECE_LOOKUP[cell.to_display]} ", display_track.even?)
        display_track += 1
      end
      rank_ind -= 1
      print "\n"
      display_track += 1
    end
    print "\n"
  end

  private

  def colorize_cell_bg(text, white)
    white ? "\e[100m#{text}\e[0m" : "\e[0m#{text}\e[0m"
  end
end

