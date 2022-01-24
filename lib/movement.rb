# frozen_string_literal: true

# lib/movement.rb

require_relative 'chess'
require_relative 'board'
require_relative 'cell'
require_relative 'piece'
require_relative 'pieces/all_pieces'

class Movement
  def initialize(game)
    @board = game.board
    @game = game
  end

  def legal_moves(cell)
    return [] if cell.empty?

    piece = cell.piece

    # Psuedo contains cells, so we can actually ask questions about it.
    psuedo = piece.moves(@board, cell.name)

    # Get the active king, and information we need.
    king = piece.is_a?(King) ? cell : active_king
    attackers, enemies = get_enemies(king)
    danger_zone = dangers(king)

    if danger_zone.include?(king)
      puts 'Check detected'
    else
      return (psuedo - danger_zone).uniq.map(&:name).sort if piece.is_a?(King)

      psuedo.map(&:name).sort
    end

    # Return names.
    # names = psuedo.map(&:name).sort
  end

  def get_enemies(king)
    attackers = []
    enemies = []
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.friendly?(cell)

        if cell.piece.moves(@board, cell.name).include?(king)
          attackers << cell
        else
          enemies << cell
        end
      end
    end
    [attackers, enemies]
  end

  def dangers(king)
    # Should return a list of cells attackers can traverse.
    result = []
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.friendly?(cell)

        result << cell.piece.captures(@board, cell.name)
      end
    end

    result.flatten.uniq
  end

  private

  def active_king
    @game.active == 'w' ? @board.wking : @board.bking
  end
end
