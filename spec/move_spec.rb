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

      it 'using reject(&:dead?) correctly filters moves down to two' do
        expect(moves.reject(&:dead?)).to include(Move).exactly(2).times
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

      it 'using reject(&:dead?) correctly filters no moves' do
        expect(moves.reject(&:dead?)).to include(Move).exactly(3).times
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

      it 'using reject(&:dead?) filters out an out of bound move' do
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

      it 'using reject(&:dead?) correctly filters no moves' do
        expect(moves.reject(&:dead?)).to include(Move).exactly(8).times
      end
    end
  end

  context 'for the given board' do
    context 'with a Rook on e2 with an obstruction and a capture available' do
      before do
        game.set_board_state('4q2k/8/4n3/8/4p3/8/rP2R3/7K w - - 0 1')
        # Rook offsets
        offsets = [[0, 1], [1, 0], [0, -1], [-1, 0]] # N, E, S, W
        offsets.each do |offset|
          moves << Move.new(board, 'e2', offset, 7)
        end
      end

      context 'testing the "before" block move generation, targeting private Move#build_move method.' do
        it 'builds all basic moves' do
          expect(moves).to include(Move).exactly(4).times
        end
  
        it 'correctly puts all cells into each move' do
          expected = [6, 3, 1, 4]
          moves.each_with_index do |path, i|
            expect(path.length).to eq(expected[i])
          end
        end
      end

      it 'using reject(&:dead?) correctly identifies no dead moves' do
        expect(moves.reject(&:dead?)).to include(Move).exactly(4).times
      end

      context 'with the north-bound path we generated' do
        it 'correctly indicates 3 enemies on the move when sending #enemies' do
          move_north = moves[0]
          expect(move_north.enemies).to eq(3)
        end

        it 'returns the correct path to the first enemy when sending #path' do
          move_north = moves[0]
          expect(move_north.valid).to include(Cell).twice
        end

        it 'returns the correct moves to the second enemy when sending #path_xray' do
          move_north = moves[0]
          expect(move_north.valid_xray).to include(Cell).exactly(4).times
        end
      end

      context 'with the west-bound path' do
        it 'correctly indicates 1 enemy on the move when sending #enemies' do
          move_west = moves[3]
          expect(move_west.enemies).to eq(1)
        end

        it 'returns the correct moves when sending #path' do
          move_west = moves[3]
          expect(move_west.valid).to include(Cell).twice
        end
      end

      context 'with the east-bound path' do
        it 'returns the correct moves when sending #path' do
          move_east = moves[1]
          expect(move_east.valid).to include(Cell).exactly(3).times
        end
      end

      context 'with the south-bound path' do
        it 'returns the correct moves when sending #path' do
          move_south = moves[2]
          expect(move_south.valid).to include(Cell).once
        end
      end
    end

    context 'with a Bishop on d3 with an obstruction and a capture available' do
      let(:moves) { [] }

      before do
        game.set_board_state('k7/8/6q1/5n2/8/3B4/4P3/KR6 w - - 0 1')
        # Clockwise from north @ 12
        offsets = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
        offsets.each do |offset|
          moves << Move.new(board, 'd3', offset, 7)
        end
      end

      context 'testing the "before" block code, targeting private Move#build_move method.' do
        it 'builds all basic moves' do
          expect(moves).to include(Move).exactly(4).times
        end

        it 'correctly puts all cells into each move' do
          expected = [4, 2, 2, 3]
          moves.each_with_index do |path, i|
            expect(path.length).to eq(expected[i])
          end
        end
      end

      it 'using reject(&:dead?) correctly identifies 1 dead move' do
        expect(moves.reject(&:dead?)).to include(Move).exactly(3).times
      end

      context 'with the north-east path' do
        it 'correctly indicates 2 enemy on the move' do
          move_north = moves[0]
          expect(move_north.enemies).to eq(2)
        end

        it 'returns the correct path to the first enemy when sending #path' do
          move_north = moves[0]
          expect(move_north.valid).to include(Cell).twice
        end

        it 'returns the correct path to all enemies when sending #path_xray' do
          move_north = moves[0]
          expect(move_north.valid_xray).to include(Cell).exactly(3).times
        end
      end

      context 'with the north-west path' do
        it 'returns the correct path when sending #path' do
          move_west = moves[3]
          expect(move_west.valid).to include(Cell).exactly(3).times
        end

        it 'returns an empty list when sending #path_xray' do
          move_west = moves[3]
          expect(move_west.valid_xray).to be_empty
        end
      end

      context 'with the south-east path' do
        it 'returns an empty list when sending #path' do
          move_east = moves[1]
          expect(move_east.valid).to be_empty
        end

        it 'returns an empty list when sending #path_xray' do
          move_east = moves[1]
          expect(move_east.valid_xray).to be_empty
        end

        it 'returns 0 when being sent #enemies' do
          move_east = moves[1]
          expect(move_east.enemies).to eq(0)
        end
      end

      context 'with the south-west path' do
        it 'returns the correct moves when sending #path' do
          move_east = moves[2]
          expect(move_east.valid).to include(Cell).once
        end

        it 'returns an empty list when sending #path_xray' do
          move_east = moves[2]
          expect(move_east.valid_xray).to be_empty
        end

        it 'returns 0 when being sent #enemies' do
          move_east = moves[2]
          expect(move_east.enemies).to eq(0)
        end
      end
    end
  end
end
