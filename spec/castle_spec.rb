# frozen_string_literal: true

# spec/castle_spec.rb

require_relative '../lib/castle'

describe CastleManager do
  let(:game) { Chess.new }
  subject(:manager) { described_class.new(game) }

  context '#update_rights' do
    context 'with only white castle rights' do
      context 'with white being the active color' do
        before do
          game.set_board_state('r3k2r/8/8/8/8/8/8/R3K2R w KQ - 0 1')
        end

        it 'updates correctly when passed the king' do
          cell = game.cell('e1')
          expect(game.castle).to eq('KQ')
          manager.update_rights(cell)
          expect(game.castle).to eq('-')
        end

        it 'updates correctly when passed the Queen side rook' do
          cell = game.cell('a1')
          expect(game.castle).to eq('KQ')
          manager.update_rights(cell)
          expect(game.castle).to eq('K')
        end

        it 'updates correctly when passed the King side rook' do
          cell = game.cell('h1')
          expect(game.castle).to eq('KQ')
          manager.update_rights(cell)
          expect(game.castle).to eq('Q')
        end
      end
    end

    context 'with castle rights for both colors' do
      context 'with white being the active color' do
        before do
          game.set_board_state('r3k2r/4p3/8/8/8/8/4P3/R3K2R w KQkq - 0 1')
        end

        it 'updates correctly when passed the king' do
          cell = game.cell('e1')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(cell)
          expect(game.castle).to eq('kq')
        end

        it 'updates correctly when passed the Queen side rook' do
          cell = game.cell('a1')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(cell)
          expect(game.castle).to eq('Kkq')
        end

        it 'updates correctly when passed the King side rook' do
          cell = game.cell('h1')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(cell)
          expect(game.castle).to eq('Qkq')
        end

        it 'does not modify rights when passed a pawn' do
          cell = game.cell('e2')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(cell)
          expect(game.castle).to eq('KQkq')
        end
      end

      context 'with black being the active color' do
        before do
          game.set_board_state('r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1')
        end

        it 'updates correctly when passed the king' do
          cell = game.cell('e8')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(cell)
          expect(game.castle).to eq('KQ')
        end

        it 'updates correctly when passed the Queen side rook' do
          cell = game.cell('a8')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(cell)
          expect(game.castle).to eq('KQk')
        end

        it 'updates correctly when passed the King side rook' do
          cell = game.cell('h8')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(cell)
          expect(game.castle).to eq('KQq')
        end

        it 'does not modify rights when passed an empty cell' do
          cell = game.cell('e7')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(cell)
          expect(game.castle).to eq('KQkq')
        end
      end
    end
  end

  context '#castle_moves' do
    context 'returns an empty array when piece is not a King' do
      before do
        game.set_board_state('r3k2r/8/8/8/8/4R3/8/R3K3 b kq - 0 1')
      end

      it 'returns an empty array when piece is not a King' do
        cell = game.cell('a8')
        expect(manager.castle_moves(cell, cell.piece.moves(game.board, cell))).to eq([])
      end
    end

    context 'when there are no castle moves available for the active color' do
      before do
        game.set_board_state('r3k2r/8/8/8/8/8/8/R3K2R w kq - 0 1')
      end

      it 'returns an empty array' do
        cell = game.cell('e1')
        expect(manager.castle_moves(cell, cell.piece.moves(game.board, cell))).to eq([])
      end
    end

    context 'when the active king is in check, and castle moves are available' do
      before do
        game.set_board_state('r3k2r/8/8/8/8/4R3/8/R3K3 b kq - 0 1')
      end

      it 'returns an empty array' do
        cell = game.cell('e8')
        expect(manager.castle_moves(cell, cell.piece.moves(game.board, cell))).to eq([])
      end
    end

    context 'when there is only queen-side castle available for active King, but is blocked' do
      before do
        game.set_board_state('r3k2r/8/8/8/8/8/8/R1N1K2R w Qkq - 0 1')
      end

      it 'returns an empty array when white is active' do
        cell = game.cell('e1')
        expect(manager.castle_moves(cell, cell.piece.moves(game.board, cell))).to eq([])
      end
    end

    context 'when there is only queen-side castle available for a black king, but it is blocked' do
      before do
        game.set_board_state('rn2k2r/8/8/8/8/8/8/R1N1K2R b Qq - 0 1')
      end

      it 'returns an empty array when black is active' do
        cell = game.cell('e8')
        expect(manager.castle_moves(cell, cell.piece.moves(game.board, cell))).to eq([])
      end
    end

    context 'when valid cells are under attack' do
      before do
        game.set_board_state('4k3/2n5/8/5N2/3r1r2/8/8/R3K2R w KQ - 0 1')
      end

      it 'returns an empty array when white has no castle options even though right is available' do
        cell = game.cell('e1')
        king_moves = game.move_manager.legal_moves(cell)
        expect(manager.castle_moves(cell, king_moves)).to eq([])
      end
    end

    context 'when only one valid castle is under attack' do
      before do
        game.set_board_state('4k2r/2n5/8/5N2/3r4/8/8/R3K2R w KQk - 0 1')
      end

      it 'returns the correct available destination cell' do
        cell = game.cell('e1')
        king_moves = game.move_manager.legal_moves(cell)
        output = manager.castle_moves(cell, king_moves)
        expect(output.length).to eq(1)
        expect(output.pop).to be_a(Cell).and have_attributes(:name => 'g1')
      end
    end

    context 'when only one valid castle is under attack' do
      before do
        game.set_board_state('r3k3/2n5/8/5N2/5r2/8/8/R3K2R w KQ - 0 1')
      end

      it 'returns the available destination cell' do
        cell = game.cell('e1')
        king_moves = game.move_manager.legal_moves(cell)
        output = manager.castle_moves(cell, king_moves)
        expect(output.length).to eq(1)
        expect(output.pop).to be_a(Cell).and have_attributes(:name => 'c1')
      end
    end

    context 'when both castle moves are available, but one is blocked by an attack' do
      before do
        game.set_board_state('r3k2r/2n5/7N/8/8/8/8/R3K2R b KQkq - 0 1')
      end

      it 'returns the correct additional available moves' do
        cell = game.cell('e8')
        king_moves = game.move_manager.legal_moves(cell)
        output = manager.castle_moves(cell, king_moves)
        expect(output.length).to eq(1)
        expect(output.pop).to be_a(Cell).and have_attributes(:name => 'c8')
      end
    end

    context 'when both castle moves are available, but both blocked by attacks' do
      before do
        game.set_board_state('r3k2r/8/1n5N/8/2R5/8/8/4K2R b Kkq - 0 1')
      end

      it 'returns an empty array' do
        cell = game.cell('e8')
        king_moves = game.move_manager.legal_moves(cell)
        expect(manager.castle_moves(cell, king_moves)).to eq([])
      end
    end


    context 'when castles are available but king movement is restricted' do
      before do
        game.set_board_state('4k3/8/1n6/6N1/8/3r1r2/8/R3K2R w KQ - 0 1')
      end

      it 'returns an empty array' do
        cell = game.cell('e1')
        king_moves = game.move_manager.legal_moves(cell)
        expect(manager.castle_moves(cell, king_moves)). to eq([])
      end
    end

    context 'when castles are available but king movement is restricted on one side' do
      before do
        game.set_board_state('4k2r/8/1n6/6N1/8/3r4/8/R3K2R w KQk - 0 1')
      end

      it 'returns the correct destination available' do
        cell = game.cell('e1')
        king_moves = game.move_manager.legal_moves(cell)
        output = manager.castle_moves(cell, king_moves)
        expect(output.length).to eq(1)
        expect(output.pop).to be_a(Cell).and have_attributes(:name => 'g1')
      end
    end
  end
end
