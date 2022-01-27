# frozen_string_literal: true

# spec/pawn_spec.rb

require_relative '../../lib/chess'
require_relative '../../lib/piece'
require_relative '../../lib/pieces/pawn'

describe Pawn do
  it 'correctly reports false when sending #slides? query' do
    expect(Pawn.new('p').slides?).to be false
  end

  context 'with the given board #1' do
    let(:game) { Chess.new }
    let(:board) { game.board }
    let(:white_p) { Pawn.new('P') }
    let(:black_p) { Pawn.new('p') }

    context 'when selecting a black pawn at h5' do
      before do
        game.set_board_state('k6q/1p6/2p5/6np/8/2PK1R2/4P3/2R5 b - - 0 1')
      end

      it 'correctly reports 3 moves when #all_paths' do
        moves = black_p.all_paths(board, 'h5')
        expect(moves).to include(Move).exactly(3).times
      end

      it 'correctly reports 2 moves when #valid_paths' do
        moves = black_p.valid_paths(board, 'h5')
        expect(moves).to include(Move).exactly(2).times
      end

      it 'correctly reports 2 destinations when sending #moves' do
        moves = black_p.moves(board, 'h5').map(&:name).sort
        expected = %w[h4 g4].sort
        expect(moves).to eq(expected)
      end
    end

    context 'when selecting a black pawn at b7' do
      before do
        game.set_board_state('k6q/1p6/2p5/6np/8/2PK1R2/4P3/2R5 b - - 0 1')
      end

      it 'correctly reports 3 moves when sent #all_paths' do
        moves = black_p.all_paths(board, 'b7')
        expect(moves).to include(Move).exactly(3).times
      end

      it 'correctly reports 2 moves when sent #valid_paths' do
        moves = black_p.valid_paths(board, 'b7')
        expect(moves).to include(Move).exactly(2).times
      end

      it 'correctly reports 3 destinations when sending #moves' do
        moves = black_p.moves(board, 'b7').map(&:name).sort
        expected = %w[b6 a6 b5].sort
        expect(moves).to eq(expected)
      end
    end

    context 'when selecting a black pawn at c6' do
      before do
        game.set_board_state('k6q/1p6/2p5/6np/8/2PK1R2/4P3/2R5 b - - 0 1')
      end

      it 'correctly reports 3 moves when sent #all_paths' do
        moves = black_p.all_paths(board, 'c6')
        expect(moves).to include(Move).exactly(3).times
      end

      it 'correctly reports 2 moves when sent #valid_paths' do
        moves = black_p.valid_paths(board, 'c6')
        expect(moves).to include(Move).exactly(3).times
      end

      it 'correctly reports 3 destinations when sending #moves' do
        moves = black_p.moves(board, 'c6').map(&:name).sort
        expected = %w[b5 d5 c5].sort
        expect(moves).to eq(expected)
      end
    end

    context 'when selecting a white pawn at c3' do
      before do
        game.set_board_state('k6q/1p6/2p5/6np/8/2PK1R2/4P3/2R5 w - - 0 1')
      end

      it 'correctly reports 3 moves when sent #all_paths' do
        moves = white_p.all_paths(board, 'c3')
        expect(moves).to include(Move).exactly(3).times
      end

      it 'correctly reports 3 moves when sent #valid_paths' do
        expect(white_p.valid_paths(board, 'c3')).to include(Move).exactly(3).times
      end

      it 'correctly reports 3 destinations when sending #moves' do
        moves = white_p.moves(board, 'c3').map(&:name).sort
        expected = %w[b4 c4 d4].sort
        expect(moves).to eq(expected)
      end
    end

    context 'when selecting a white pawn at e2' do
      before do
        game.set_board_state('k6q/1p6/2p5/6np/8/2PK1R2/4P3/2R5 w - - 0 1')
      end

      it 'correctly reports 1 move when sent #valid_paths' do
        moves = white_p.valid_paths(board, 'e2')
        expect(moves).to include(Move).exactly(1).times
      end

      it 'correctly reports 2 destinations when sending #moves' do
        moves = white_p.moves(board, 'e2').map(&:name).sort
        expected = %w[e3 e4].sort
        expect(moves).to eq(expected)
      end
    end
  end
end