# frozen_string_literal: true

# lib/ui.rb

class UI
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

  def initialize(game)
    @game = game
  end

  def show_board(moves=[])
    color_track = 0
    cols = ('a'..'h').to_a
    print '  '
    cols.each { |char| print " #{char} " }
    print "\n"

    rank_ind = 8
    @game.board.data.each do |rank|
      print "#{rank_ind} "
      rank.each do |cell|
        if moves.include?(cell.name) && cell.empty?
          print colorize_cell_bg(" \e[36m◇\e[0m ", color_track.even?)
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

  def show_welcome
    puts <<~WELCOME
          Welcome to Chess! This version of Chess is meant to be played by two players.
          All the standard rules of Chess apply. Enjoy!
        WELCOME
  end

  def show_gameover
    return unless @game.checkmate.gameover?

    # Check which player is marked active after making a checkmate move.
    # It should be the losing color that is active, proceeding on that assumption.
    winner = @game.active == 'w' ? 'Black' : 'White'
    checkmate = @game.checkmate.checkmate?
    draw = @game.checkmate.draw?
    puts checkmate ? "Congratulations! #{winner} wins this game!" : "The game ended in a #{draw ? 'draw' : 'stalemate'}."
  end

  def prompt_pick_piece
    # Prompt the active player to pick piece
    # Check that the entered destination is valid (ie, we get a cell back from game)
    # Check that the cell contains a piece that is the same color as the active color.
    # Return the cell if we pass these conditions
  end

  def prompt_pick_move(cell, eligible)
    # Prompt the active player to pick a move.
    # We need the cell so we can display the current piece and location info.
    # Show the current selected piece and the list of moves.
    # Check that entered information is included in eligible.
  end

  def prompt_play_again
    # Once the game is over, do we want to play again?
  end

  private

  def colorize_cell_bg(text, white)
    white ? "\e[100m#{text}\e[0m" : "\e[0m#{text}\e[0m"
  end

  def colorize_cell_bg_capture(text)
    "\e[41m#{text}\e[0m"
  end
end

