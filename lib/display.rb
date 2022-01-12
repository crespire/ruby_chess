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

  def show_board(board: @board, moves: [])
    color_track = 0
    cols = ('a'..'h').to_a
    print '  '
    cols.each { |char| print " #{char} " }
    print "\n"
    moves.map! { |move| move.gsub('x', '') }

    rank_ind = 8
    board.data.each do |rank|
      print "#{rank_ind} "
      rank.each do |cell|
        if moves.include?(cell.name) && cell.empty?
          print colorize_cell_bg("\e[31m ◇ \e[0m", color_track.even?)
        elsif moves.include?(cell.name) && !cell.empty?
          print colorize_cell_bg_capture(" #{PIECE_LOOKUP[cell.to_display]} ")
        else
          print colorize_cell_bg(" #{PIECE_LOOKUP[cell.to_display]} ", color_track.even?)
        end
        color_track += 1
      end
      print "\n"
      rank_ind -= 1
      color_track += 1
    end
    print "\n"
  end

  private

  def colorize_cell_bg(text, white)
    white ? "\e[100m#{text}\e[0m" : "\e[0m#{text}\e[0m"
  end

  def colorize_cell_bg_capture(text)
    "\e[41m#{text}\e[0m"
  end
end

