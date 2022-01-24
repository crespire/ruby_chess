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
    psuedo = piece.moves(@board, cell.name)

    # Psuedo contains cells, so we can actually ask questions about it.

    # Returns names.
    names = psuedo.map(&:name).sort
  end

  def get_enemies
    king = active_king
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

  def king_threat_boards
    king = active_king
    attackers, enemies = get_enemies
    # This function should generate two arrays.
    # The first array should be a list of all the moves enemies can go on. This is the danger zone array.
    # The second array shoudl be a list of all the valid moves enmies can go on. This is the attacked square array.
    { 'danger_board' => [], 'attacks_board' => [] }
  end

  private

  def active_king
    @game.active == 'w' ? @board.wking : @board.bking
  end
end
