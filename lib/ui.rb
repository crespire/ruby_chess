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
          print colorize_cell_bg("\e[36m ◇ \e[0m", color_track.even?)
        elsif moves.include?(cell.name) && !cell.empty?
          print colorize_cell_bg_capture(" #{PIECE_LOOKUP[cell.to_display]} ")
        else
          print colorize_cell_bg(" #{PIECE_LOOKUP[cell.to_display]} ", color_track.even?)
        end
        color_track += 1
      end
      print "  Active: #{@game.active == 'w' ? 'White' : 'Black'}" if rank_ind == 7
      print "  Castle: #{@game.castle}" if rank_ind == 6
      print "  Passant: #{@game.passant}" if rank_ind == 5
      print "  Half-clock: #{@game.half}" if rank_ind == 4
      print "  Full-clock: #{@game.full}" if rank_ind == 3
      print "  Ply: #{@game.ply}" if rank_ind == 2
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
    active_string = @game.active == 'w' ? 'White' : 'Black'
    puts "You can enter 'save' to save the current game, or 'exit' to stop the program."
    loop do
      print "#{active_string}, pick a piece to play using Chess notation: "
      input = gets.chomp.downcase
      return 'save' if input == 'save'
      return 'exit' if input == 'exit'

      cell = @game.cell(input)
      puts 'This destination is out of bounds.' if cell.nil?
      next if cell.nil?

      puts 'This destination is empty.' if cell.empty?
      next if cell.empty?

      piece_color = cell.piece.color
      owned = piece_color == @game.active
      puts 'This piece is not yours.' unless owned
      next unless owned

      avail_moves = @game.move_manager.legal_moves(cell).length
      puts 'This piece has no legal moves.' unless owned && avail_moves.positive?
      return cell if owned && avail_moves.positive?
    end
  end

  def prompt_pick_move(cell, eligible)
    puts "Available moves for #{cell.piece.fen}#{cell.name}: #{eligible.join(', ')}"
    loop do
      print "Enter 'back' to pick another piece, or select a move: "
      input = gets.chomp.downcase
      return nil if input == 'back'

      puts 'Not a valid selection.' unless eligible.include?(input)
      next unless eligible.include?(input)

      return input
    end
  end

  def prompt_pawn_promotion(cell)
    puts "Congratulations! A #{cell.piece.color == 'w' ? 'white' : 'black'} pawn has made it to promotion."
    puts 'You can select a (q)ueen, a k(n)ight, (r)ook or (b)ishop.'
    loop do
      print 'Enter the promotion you would like: '
      input = gets.chomp.downcase
      puts 'Invalid input, try again.' unless %w[q n r b].include?(input)
      next unless %w[q n r b].include?(input)

      fen = @game.active == 'w' ? input.upcase : input.downcase
      return fen
    end
  end

  def prompt_play_again
    puts "Play again? "
    # Once the game is over, do we want to play again?
  end

  def prompt_save
    loop do
      print 'Would you like to load a game? '
      input = gets.chomp.downcase
      puts 'Invalid input, try asgain.' unless %w[y n].include?(input)
      next unless %w[y n].include?(input)

      input == 'y' ? 'load' : 'new'
    end
    
  end

  def prompt_continue
    print 'Press any key to continue.'
    STDIN.getch
    clear_console
  end

  def clear_console
    system("clear") || system("cls")
  end

  private

  def colorize_cell_bg(text, white)
    white ? "\e[100m#{text}\e[0m" : "\e[0m#{text}\e[0m"
  end

  def colorize_cell_bg_capture(text)
    "\e[41m#{text}\e[0m"
  end
end
