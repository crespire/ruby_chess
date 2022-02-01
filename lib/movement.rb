# frozen_string_literal: true

# lib/movement.rb

require_relative 'chess'
require_relative 'board'
require_relative 'cell'
require_relative 'castle'
require_relative 'piece'
require_relative 'pieces/all_pieces'

class Movement
  def initialize(game)
    @game = game
  end

  def legal_moves(cell)
    return [] if cell.empty?

    piece = cell.piece
    psuedo = piece.moves(@game.board, cell.name)
    king = piece.is_a?(King) ? cell : active_king
    attackers, = get_enemies(king)
    danger_zone = dangers(king)
    no_go_zone = attacks(king)
    return king_moves_helper(psuedo, cell, danger_zone, no_go_zone) if piece.is_a?(King)

    psuedo = pawn_moves_helper(psuedo, cell) if piece.is_a?(Pawn)
    if no_go_zone.include?(king)
      to_verify = check_helper(piece, psuedo, attackers)
      return to_verify if to_verify.empty?

      result = []
      to_verify.each do |verify_cell|
        result << verify_cell if move_legal?(@game, king, cell, verify_cell)
      end
      result.map(&:name).sort
    else
      result = []
      candidates = []
      @game.board.data.each do |rank|
        rank.each do |check_cell|
          next if check_cell.empty? || cell.friendly?(check_cell)
          next unless check_cell.piece.slides?

          enemy_slides = check_cell.piece.valid_paths(@game.board, check_cell)
          candidates = enemy_slides.select do |move|
            move.valid_xray.include?(active_king) && move.valid.include?(cell) && move.enemies == 2
          end
          candidates.each do |move|
            result += (move.valid << move.origin) & psuedo
          end
        end
      end

      candidates.empty? ? psuedo.map(&:name).sort : result.flatten.uniq.map(&:name).sort
    end
  end

  ##
  # Returns a two element array that partitions enemies.
  # The first sub-array holds pieces that directly attack the king
  # The second holds all other active enemy pieces.
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

  ##
  # Returns a list of all moves enemies can make.
  def dangers(king, game = @game)
    result = []
    game.board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.friendly?(cell)

        result << cell.piece.captures(game.board, cell.name)
      end
    end

    result.flatten.uniq
  end

  ##
  # Returns a list of captures that can threaten the given king.
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

  ##
  # Returns the cell of the active side's King.
  def active_king
    @game.active == 'w' ? @game.board.wking : @game.board.bking
  end

  ##
  # Helper method to filter illegal King moves from their basic moves.
  def king_moves_helper(psuedo, origin, danger_zone, no_go_zone)
    puts "Inside King Helper"
    to_test = (danger_zone - no_go_zone) & psuedo
    return (psuedo - no_go_zone).uniq.map(&:name).sort if to_test.empty?

    puts "We have items to test"
    to_test.each do |destination|
      legal = move_legal?(@game, active_king, origin, destination)
      psuedo.delete_if { |cell| cell.name == destination.name } unless legal
    end

    interim = (psuedo - no_go_zone).uniq.map(&:name)
    p interim
    puts "Calling castle manager"
    castle = @game.castle_manager.castle_moves(origin, interim)
    p castle
    (interim + castle.map(&:name)).flatten.sort
  end

  ##
  # Helper method to filter illegal pawn moves from their basic moves.
  def pawn_moves_helper(psuedo, cell)
    captures = cell.piece.captures(@game.board, cell.name).compact
    passant = passant_capture(cell.piece)
    captures.each do |target_cell|
      psuedo.delete(target_cell) if target_cell.empty? || (target_cell.full? && cell.friendly?(target_cell))
    end
    psuedo << passant if passant && captures.include?(passant)

    rank_dir = cell.piece.white? ? 1 : -1
    step_one = @game.board.cell(cell.name, 0, rank_dir)
    step_two = @game.board.cell(cell.name, 0, (rank_dir * 2))
    psuedo.delete(step_one) if step_one && psuedo.include?(step_one) && step_one.full?
    if step_two && psuedo.include?(step_two) && (step_one.full? || (step_one.empty? && step_two.full?))
      psuedo.delete(step_two)
    end

    psuedo.compact
  end

  ##
  # Tests if the target move will result in a check.
  def move_legal?(game_to_copy, king_to_check, origin, destination)
    game = Marshal.load(Marshal.dump(game_to_copy))
    copy_origin = game.cell(origin.name)
    copy_destination = game.cell(destination.name)
    copy_king = origin == king_to_check ? game.cell(destination.name) : game.cell(king_to_check.name)
    game.move_piece(copy_origin, copy_destination)
    moves_manager = Movement.new(game)
    attackers, = moves_manager.get_enemies(copy_king, game)
    attackers.empty?
  end

  ##
  # Runs through the possible conditions of a check to generate moves.
  # Gotcha: piece will never be King.
  def check_helper(piece, psuedo, attackers)
    return [] if attackers.length > 1

    passant = passant_capture(piece)
    enemy_cell = attackers.pop
    return [passant] if passant && psuedo.include?(passant)
    return [enemy_cell] if psuedo.include?(enemy_cell)

    enemy_paths = enemy_cell.piece.valid_paths(@game.board, enemy_cell)
    attack_path = enemy_paths.select { |move| move.include?(active_king) }.pop
    (attack_path & psuedo)
  end

  ##
  # Returns cell if piece is eligible to en passant capture.
  def passant_capture(piece)
    passant_capture = piece.is_a?(Pawn) && @game.passant != '-'
    passant_capture ? @game.board.cell(@game.passant) : nil
  end
end
