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
    king = piece.is_a?(King) ? cell : active_king
    attackers, enemies = get_enemies(king)
    danger_zone = dangers(king)
    no_go_zone = attacks(king)
    return king_helper(psuedo, cell, danger_zone, no_go_zone) if piece.is_a?(King)

    # We should remove invalid pawn captures here.

    if no_go_zone.include?(king)
      return [] if attackers.length > 1 # Double check, only King has moves

      results = []
      enemy_cell = attackers.pop
      return [enemy_cell.name] if psuedo.include?(enemy_cell)

      # Test block available?

      results.map(&:name).sort
    else
      enemies.length
      psuedo.map(&:name).sort
    end
  end

  def get_enemies(king, game = @game)
    attackers = []
    enemies = []
    game.board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.friendly?(cell)

        if cell.piece.moves(game.board, cell.name).include?(king)
          attackers << cell
        else
          enemies << cell
        end
      end
    end
    [attackers, enemies]
  end

  def dangers(king, game = @game)
    # Based on all_paths
    result = []
    game.board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.friendly?(cell)

        result << cell.piece.captures(game.board, cell.name)
      end
    end

    result.flatten.uniq
  end

  def attacks(king, game = @game)
    result = []
    game.board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.friendly?(cell)

        piece = cell.piece
        to_add = piece.is_a?(Pawn) ? piece.captures(game.board, cell.name) : piece.moves(game.board, cell.name)
        result << to_add
      end
    end

    result.flatten.uniq
  end

  private

  def active_king
    @game.active == 'w' ? @board.wking : @board.bking
  end

  def king_helper(psuedo, origin, danger_zone, no_go_zone)
    # Find difference between danger_zone and attacks and union with psuedo
    to_test = (danger_zone - no_go_zone) & psuedo

    # Test each move to determine if legal
    to_test.each do |destination|
      game_deep_copy = Marshal.load(Marshal.dump(@game))
      legal = move_legal?(game_deep_copy, origin, destination)
      psuedo.delete_if { |cell| cell.name == destination.name } unless legal
    end

    # Purge all other attacks and return.
    (psuedo - no_go_zone).uniq.map(&:name).sort
  end

  def move_legal?(game, origin, destination)
    copy_origin = game.cell(origin.name)
    copy_destination = game.cell(destination.name)
    game.move_piece(copy_origin, copy_destination)
    moves_manager = Movement.new(game)
    attackers, = moves_manager.get_enemies(copy_origin)
    attackers.empty?
  end
end
