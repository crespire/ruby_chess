# frozen_string_literal: true

# spec/piece_spec.rb

require_relative '../lib/move'
require_relative '../lib/chess'

describe Move do
  let(:game) { Chess.new }
  let(:board) { game.board }
  let(:moves) { Array.new }

  ##
  # Use all_paths on the pieces to verify all moves are generated, then we can
  # test the filtering, and make sure the right destinations are made.
  context 'on init' do
    it 'returns an empty move if initalized with step = 0' do
      move = Move.new(board, 'a7', [0, -1], 0)
      p move
      expect(move.dead?).to be true
    end
  end

  context 'with single pieces on a starting board' do
    context 'with a Knight at b8' do
      it 'using reject(&:dead?) correctly filters moves down to two' do
        black_knight = Piece::from_fen('n')
        moves = black_knight.all_paths(board, 'b8')
        expect(moves.reject(&:dead?)).to include(Move).exactly(2).times
      end
    end

    context 'with a black pawn on d7' do
      it 'using reject(&:dead?) correctly filters no moves' do
        black_pawn = Piece::from_fen('p')
        moves = black_pawn.all_paths(board, 'd7')
        expect(moves.reject(&:dead?)).to include(Move).exactly(3).times
      end
    end

    context 'with a white pawn on h3' do
      it 'using reject(&:dead?) filters out an out of bound move' do
        white_pawn = Piece::from_fen('P')
        moves = white_pawn.all_paths(board, 'h3')
        expect(moves.reject(&:dead?)).to include(Move).exactly(2).times
      end
    end

    context 'with a white king on d5' do
      it 'using reject(&:dead?) correctly filters no moves' do
        white_king = Piece::from_fen('K')
        moves = white_king.all_paths(board, 'd5')
        expect(moves.reject(&:dead?)).to include(Move).exactly(8).times
      end
    end
  end

  context 'for the given board' do
    context 'with a Rook on e2 with an obstruction and a capture available' do
      let(:white_rook) { Piece::from_fen('R') }
      let(:moves) { white_rook.all_paths(board, 'e2') }

      before do
        game.set_board_state('4q2k/8/4n3/8/4p3/8/rP2R3/7K w - - 0 1')
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
          expect(move_north.valid).to include(Cell).exactly(2).times
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
          expect(move_west.valid).to include(Cell).exactly(2).times
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
          expect(move_south.valid).to include(Cell).exactly(1).times
        end
      end
    end

    context 'with a Bishop on d3 with an obstruction and a capture available' do
      let(:white_bishop) { Piece::from_fen('B') }
      let(:moves) { white_bishop.all_paths(board, 'd3') }

      before do
        game.set_board_state('k7/8/6q1/5n2/8/3B4/4P3/KR6 w - - 0 1')
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
