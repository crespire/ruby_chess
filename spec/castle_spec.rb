# frozen_string_literal: true

# spec/castle_spec.rb

require_relative '../lib/castle'

describe Castle do
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
        expect(manager.castle_moves(cell)).to eq([])
      end
    end

    context 'when there are no castle moves available for the active color' do
      before do
        game.set_board_state('r3k2r/8/8/8/8/8/8/R3K2R w kq - 0 1')
      end

      it 'returns an empty array' do
        cell = game.cell('e1')
        expect(manager.castle_moves(cell)).to eq([])
      end
    end

    context 'when the active king is in check, and castle moves are available' do
      before do
        game.set_board_state('r3k2r/8/8/8/8/4R3/8/R3K3 b kq - 0 1')
      end

      it 'returns an empty array' do
        cell = game.cell('e8')
        expect(manager.castle_moves(cell)).to eq([])
      end
    end

    context 'when there is only queen-side castle available for active King, but is blocked' do
      before do
        game.set_board_state('r3k2r/8/8/8/8/8/8/R1N1K2R w Qkq - 0 1')
      end

      it 'returns an empty array when white is active' do
        cell = game.cell('e1')
        expect(manager.castle_moves(cell)).to eq([])
      end
    end

    context 'when there is only queen-side castle available for a black king, but it is blocked' do
      before do
        game.set_board_state('rn2k2r/8/8/8/8/8/8/R1N1K2R b Qq - 0 1')
      end

      it 'returns an empty array when black is active' do
        cell = game.cell('e8')
        expect(manager.castle_moves(cell)).to eq([])
      end
    end

    context 'when valid cells are under attack' do
      before do
        game.set_board_state('4k3/2n5/8/5N2/3r1r2/8/8/R3K2R w KQ - 0 1')
      end

      it 'returns an empty array when white has no castle options even though right is available' do
        cell = game.cell('e1')
        expect(manager.castle_moves(cell)).to eq([])
      end
    end

    context 'when only one valid castle is under attack' do
      before do
        game.set_board_state('4k2r/2n5/8/5N2/3r4/8/8/R3K2R w KQk - 0 1')
      end

      it 'returns a cell' do
        cell = game.cell('e1')
        expect(manager.castle_moves(cell)).to include(Cell).exactly(1).times
      end
    end
  end
end