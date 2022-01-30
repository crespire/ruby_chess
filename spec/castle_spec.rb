# frozen_string_literal: true

# spec/castle_spec.rb

require_relative '../lib/board'
require_relative '../lib/chess'
require_relative '../lib/castle'

describe Castle do
  context '#update_rights' do
    let(:game) { Chess.new }
    subject(:manager) { described_class.new(game) } 

    context 'with only white castle rights' do
      context 'with white being the active color' do
        before do
          game.set_board_state('r3k2r/8/8/8/8/8/8/R3K2R w KQ - 0 1')
        end

        it 'updates correctly when passed the king' do
          cell = game.cell('e1')
          expect(game.castle).to eq('KQ')
          manager.update_rights(game, cell)
          expect(game.castle).to eq('-')
        end

        it 'updates correctly when passed the Queen side rook' do
          cell = game.cell('a1')
          expect(game.castle).to eq('KQ')
          manager.update_rights(game, cell)
          expect(game.castle).to eq('K')
        end

        it 'updates correctly when passed the King side rook' do
          cell = game.cell('h1')
          expect(game.castle).to eq('KQ')
          manager.update_rights(game, cell)
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
          manager.update_rights(game, cell)
          expect(game.castle).to eq('kq')
        end

        it 'updates correctly when passed the Queen side rook' do
          cell = game.cell('a1')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(game, cell)
          expect(game.castle).to eq('Kkq')
        end

        it 'updates correctly when passed the King side rook' do
          cell = game.cell('h1')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(game, cell)
          expect(game.castle).to eq('Qkq')
        end

        it 'does not modify rights when passed a pawn' do
          cell = game.cell('e2')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(game, cell)
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
          manager.update_rights(game, cell)
          expect(game.castle).to eq('KQ')
        end

        it 'updates correctly when passed the Queen side rook' do
          cell = game.cell('a8')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(game, cell)
          expect(game.castle).to eq('KQk')
        end

        it 'updates correctly when passed the King side rook' do
          cell = game.cell('h8')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(game, cell)
          expect(game.castle).to eq('KQq')
        end

        it 'does not modify rights when passed an empty cell' do
          cell = game.cell('e7')
          expect(game.castle).to eq('KQkq')
          manager.update_rights(game, cell)
          expect(game.castle).to eq('KQkq')
        end
      end
    end
  end
end