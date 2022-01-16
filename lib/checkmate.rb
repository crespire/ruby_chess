# frozen_string_literal: true

# lib/movement.rb

require_relative 'movement'

class Checkmate
  def initialize(board)
    @board = board
    @movement = Movement.new(@board)
  end

  def check?
    bking = get_king(@board.bking)
    wking = get_king(@board.wking)
    return nil if bking.empty? || wking.empty?

    direct_attacks = @board.active == 'w' ? @movement.under_attack?(wking) : @movement.under_attack?(bking)
    direct_attacks.length.positive?
  end

  def checkmate?
    bking = get_king(@board.bking)
    wking = get_king(@board.wking)
    return nil if bking.empty? || wking.empty?
    return false unless check?

    # We are in a potential checkmate situation.
    active_king = @board.active == 'w' ? wking : bking
    moves = 0
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || cell.capture?(active_king.occupant)

        moves += @movement.valid_moves(cell).length
      end
    end
    moves.zero?
  end

  def stalemate?
    bking = get_king(@board.bking)
    wking = get_king(@board.wking)
    return nil if bking.empty? || wking.empty?

    active_king = @board.active == 'w' ? wking : bking
    moves = 0
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || cell.capture?(active_king.occupant)

        moves += @movement.valid_moves(cell).length
      end
    end

    moves.zero?
  end

  private

  def get_king(reference)
    case reference
    when String
      king = @board.cell(reference)
    when reference
      king = reference
    else
      'Something went wrong'
    end

    king
  end
end