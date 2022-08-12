# frozen_string_literal: true

# lib/checkmate.rb

require_relative 'movement'

class CheckmateManager
  def initialize(game)
    @game = game
    @moves_manager = game.move_manager
  end

  def gameover?
    checkmate? || stalemate? || draw?
  end

  def check?
    king = @game.active_king
    return nil if king.nil? || king.empty?

    attackers, = @moves_manager.get_enemies(king)
    attackers.length.positive?
  end

  def checkmate?
    king = @game.active_king
    return nil if king.empty?
    return false unless check?

    moves = 0
    @game.board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.hostile?(cell.piece)

        moves += @moves_manager.legal_moves(cell).length
      end
    end
    moves.zero?
  end

  def stalemate?
    king = @game.active_king
    return nil if king.empty?
    return false if checkmate?

    moves = 0
    @game.board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.hostile?(cell.piece)

        moves += @moves_manager.legal_moves(cell).length
      end
    end

    moves.zero?
  end

  def three_fold?
    @game.fen_history.tally.value?(3)
  end

  def too_many_moves?
    @game.half >= 50
  end

  def insufficient_materials?
    return true if @game.board.active_pieces == 2 && @game.board.bking && @game.board.wking

    w_bishop = @game.board.find_piece('B')
    b_bishop = @game.board.find_piece('b')
    return true if @game.board.active_pieces == 3 && @game.board.bking && @game.board.wking && (w_bishop || b_bishop)

    w_knight = @game.board.find_piece('N')
    b_knight = @game.board.find_piece('n')
    return true if @game.board.active_pieces == 3 && @game.board.bking && @game.board.whink && (w_knight || b_knight)

    false
  end

  def draw?
    three_fold? || too_many_moves? || insufficient_materials?
  end
end
