# frozen_string_literal: true

# spec/pawn_spec.rb

require_relative '../../lib/chess'
require_relative '../../lib/piece'
require_relative '../../lib/pieces/pawn'

describe Pawn do
  it 'correctly reports false when sending #slides? query' do
    expect(Pawn.new('p').slides?).to be false
  end

  context 'with the given board' do
    let(:game) { Chess.new }
    let(:board) { game.board }
    let(:white_p) { Pawn.new('P') }
    let(:black_p) { Pawn.new('p') }

    before do
      game.set_board_state('k6q/1p6/8/6np/8/2PK1R2/4P3/2R5 w - - 0 1')
    end

    context 'when selecting a black pawn at h5' do
      it 'correctly reports 3 moves when asked' do
        moves = black_p.valid_paths(board, 'h5')
        expect(moves).to include(Move).exactly(2).times
      end
    end

    context 'when selecting a black pawn at b7' do
      it 'correctly reports 3 moves when asked' do
        moves = black_p.valid_paths(board, 'b7')
        expect(moves).to include(Move).exactly(3).times
      end
    end

    context 'when selecting a white pawn at c3' do
      it 'correctly reports 3 moves when asked' do
        moves = white_p.valid_paths(board, 'c3')
        expect(moves).to include(Move).exactly(3).times
      end
    end

    context 'when selecting a white pawn at e2' do
      it 'correctly reports 1 move when asked' do
        moves = white_p.valid_paths(board, 'e2')
        expect(moves).to include(Move).exactly(1).times
      end
    end
  end
end