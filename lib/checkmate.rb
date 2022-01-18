# frozen_string_literal: true

# lib/movement.rb

require_relative 'movement'

class Checkmate
  def initialize(game)
    @game = game
    @board = game.board
    @moves_manager = Movement.new(game)
  end

  def check?
    bking = get_king(@board.bking)
    wking = get_king(@board.wking)
    return nil if bking.empty? || wking.empty?

    threats = @game.active == 'w' ? @moves_manager.attacks_on(wking) : @moves_manager.attacks_on(bking)
    threats.length.positive?
  end

  def checkmate?
    bking = get_king(@board.bking)
    wking = get_king(@board.wking)
    return nil if bking.empty? || wking.empty?
    return false unless check?

    # We are in a potential checkmate situation.
    active_king = @game.active == 'w' ? wking : bking
    moves = 0
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || cell.capture?(active_king.occupant)

        moves += @moves_manager.valid_moves(cell).length
      end
    end
    moves.zero?
  end

  def stalemate?
    bking = get_king(@board.bking)
    wking = get_king(@board.wking)
    return nil if bking.empty? || wking.empty?
    return false if checkmate?

    active_king = @game.active == 'w' ? wking : bking
    moves = 0
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || cell.capture?(active_king.occupant)

        moves += @moves_manager.valid_moves(cell).length
      end
    end

    moves.zero?
  end

  private

  def get_king(reference)
    case reference
    when String
      king = @game.cell(reference)
    when reference
      king = reference
    else
      raise Error 'Something went wrong'
    end

    king
  end
end