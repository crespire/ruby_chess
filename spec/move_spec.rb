# frozen_string_literal: true

# spec/piece_spec.rb

require_relative '../lib/move'
require_relative '../lib/chess'
require_relative '../lib/board'
require_relative '../lib/piece'
require_relative '../lib/pieces/all_pieces'

describe Move do
  let(:game) { Chess.new }
  let(:board) { game.board }
  let(:moves) { Array.new }

  ##
  # Through out this file, we will be using a before statement to set up all
  # "pieces", as I need to unit test Move so that I can make sure it's
  # generating all the right objects, but we know we will be disarding some
  # moves that are dead. We will further be filtering the final "Move" objects
  # based basic movement rules, but we will be doing that inside each piece,
  # so I don't want to built it in to the general move object.
  #
  # As an example, I want pawns to return all 3 moves, but forward diagonal
  # is not a valid move unless a capture is available. This type of change
  # or check is best implemented in each piece, not the generic move. Its
  # goal should just be to return valid in-bound locations, regardless of
  # whether that square is occupied or free, etc.
  #
  # To that end, I'm going to set up "pieces" using a before statement to
  # faciliate testing, even though the real objects exist already.

  context 'with single pieces on a starting board' do
    context 'with a Knight at b8' do
      before do
        # Knight offsets
        offsets = [[2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2], [1, 2]] #[file, rank] offset pairs
        offsets.each do |offset|
          moves << Move.new(board, 'b8', offset)
        end
      end

      it 'builds all basic moves given a knight on the starting board' do
        expect(moves).to include(Move).exactly(8).times
      end

      it 'correctly reports three moves after removing dead moves' do
        expect(moves.reject(&:dead?)).to include(Move).exactly(3).times
      end
    end

    context 'with a black pawn on d7' do
      before do
        # Black pawn offsets
        offsets = [[0, -1], [1, -1], [-1, -1]]
        offsets.each_with_index do |offset, i|
          moves << Move.new(board, 'd7', offset, (i.zero? ? 2 : 1))
        end
      end

      it 'with a black pawn on d7, builds all basic moves' do
        expect(moves).to include(Move).exactly(3).times
      end
    end

    context 'with a white pawn on h3' do
      before do
        # White Pawn offsets
        offsets = [[0, 1], [1, 1], [-1, 1]]
        offsets.each_with_index do |offset, i|
          moves << Move.new(board, 'h3', offset, (i.zero? ? 2 : 1))
        end
      end

      it 'with a white pawn on h3, builds all basic moves' do
        expect(moves).to include(Move).exactly(3).times
        expect(moves.reject(&:dead?)).to include(Move).exactly(2).times
      end
    end

    context 'with a white king on d5' do
      before do
        # King offsets
        offsets = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]] #[file, rank] offset pairs
        offsets.each do |offset|
          moves << Move.new(board, 'd5', offset)
        end
      end

      it 'builds all basic moves' do
        expect(moves).to include(Move).exactly(8).times
      end

      it 'correctly no moves dead' do
        expect(moves.reject(&:dead?)).to include(Move).exactly(8).times
      end
    end
  end

  context 'for the given board' do
    context 'with a Rook on e2 with an obstruction and a capture available' do
      before do
        game.set_board_state('4q2k/8/4n3/8/4p3/8/1P2R3/7K w - - 0 1')
        # Rook offsets
        offsets = [[0, 1], [1, 0], [0, -1], [-1, 0]] # N, E, S, W
        offsets.each do |offset|
          moves << Move.new(board, 'e2', offset, 7)
        end
      end

      it 'builds all basic moves' do
        expect(moves).to include(Move).exactly(4).times
      end

      it 'correctly identifies no dead moves' do
        expect(moves.reject(&:dead?)).to include(Move).exactly(4).times
      end

      it 'correctly puts all cells into each move' do
        expected = [6, 3, 1, 4]
        moves.each_with_index do |path, i|
          expect(path.length).to eq(expected[i])
        end
      end

      context 'with the north-bound path' do
        it 'correctly indicates when a move has a capture' do
          move_north = moves[0]
          expect(move_north.capture?).to be true
          expect(move_north.friendly?).to be false
        end

        it 'correctly indicates 3 enemies on the move' do
          move_north = moves[0]
          expect(move_north.enemies).to eq(3)
        end

        it 'returns nil when sending #path_to_friendly' do
          move_north = moves[0]
          expect(move_north.path_friendly).to be nil
        end

        it 'returns the correct path to the first enemy when sending #path_to_enemy' do
          move_north = moves[0]
          expect(move_north.path_enemy.length).to eq(2)
        end

        it 'returns the correct path to all enemies when sending #path_xray_to_enemies' do
          move_north = moves[0]
          expect(move_north.path_xray_enemies.length).to eq(4)
        end
      end

      context 'with the west-bound path' do
        it 'correctly indicates when a move has an obstruction' do
          move_west = moves[3]
          expect(move_west.friendly?).to be true
          expect(move_west.capture?).to be false
        end

        it 'returns the correct path when sending #path_to_friendly' do
          move_west = moves[3]
          expect(move_west.path_friendly.length).to eq(2)
        end

        it 'returns nil when sending #path_to_enemy' do
          move_west = moves[3]
          expect(move_west.path_enemy).to be nil
        end
      end

      context 'with the east-bound path' do
        it 'correctly indicates the move has no capture or obstruction' do
          move_east = moves[1]
          expect(move_east.friendly?).to be false
          expect(move_east.capture?).to be false
        end

        it 'returns nil when sending #path_to_friendly' do
          move_east = moves[1]
          expect(move_east.path_friendly).to be nil
        end

        it 'returns nil when sending #path_to_enemy' do
          move_east = moves[1]
          expect(move_east.path_enemy).to be nil
        end
      end
    end
  end
end
