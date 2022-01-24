# frozen_string_literal: true

# spec/rook_spec.rb

require_relative '../../lib/chess'
require_relative '../../lib/piece'
require_relative '../../lib/pieces/rook'

describe Rook do
  it 'correctly reports true when sending #slides? query' do
    expect(Rook.new('R').slides?).to be true
  end

  context 'with the given board' do
    let(:game) { Chess.new }
    let(:board) { game.board }
    let(:white_r) { Rook.new('R') }

    before do
      game.set_board_state('k6q/1p6/8/6np/8/2P1QR2/4P1P1/K1R5 w - - 0 1')
    end

    it 'correctly reports 3 moves when asked' do
      moves = white_r.moves(board, 'f3')
      expect(moves).to include(Move).exactly(3).times
    end

    it 'correctly generates valid basic moves' do
      moves = white_r.moves(board, 'f3')
      move_names = moves.map { |move| move.map(&:name) }.flatten.sort
      expected = %w[f1 f2 f4 f5 f6 f7 f8 g3 h3].sort
      expect(move_names).to eq(expected)
    end
  end
end