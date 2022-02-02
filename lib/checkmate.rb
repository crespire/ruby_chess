# frozen_string_literal: true

# lib/movement.rb

require_relative 'movement'

class Checkmate
  def initialize(game)
    @game = game
    @moves_manager = game.move_manager
  end

  def gameover?
    checkmate? || stalemate? || draw?
  end

  def check?
    king = find_king
    return nil if king.empty?

    attackers, = @moves_manager.get_enemies(king)
    attackers.length.positive?
  end

  def checkmate?
    king = find_king
    return nil if king.empty?
    return false unless check?

    # We are in a potential checkmate situation.
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
    king = find_king
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

  def draw?
    return true if @game.half >= 50
    return true if @game.board.active_pieces == 2 && @game.board.bking && @game.board.wking
  end

  private

  def find_king
    @game.active == 'w' ? @game.board.wking : @game.board.bking
  end
end
