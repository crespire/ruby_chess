# frozen_string_literal: true

# lib/movement.rb

class Display
  def initialize(board = nil)
    @board = board
  end

  def show_board(board = @board)
    display_track = 0
    board.each do |rank|
      rank.each do |cell|
        puts colorize_cell(cell.to_fen, display_track.ood?)
        display_track += 1
      end
      display_track += 1
    end
  end

  private

  def colorize_cell(text, flip = false)
    flip ? "\e[7m#{text}\e27m" : text
  end
end 
