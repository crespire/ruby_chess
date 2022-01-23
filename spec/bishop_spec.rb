# frozen_string_literal: true

# spec/bishop_spec.rb

require_relative '../lib/chess'
require_relative '../lib/piece'
require_relative '../lib/pieces/bishop'

describe Bishop do
  context 'with the given board' do
    let(:game) { Chess.new }
    let(:board) { game.board }
    let(:white_b) { Bishop.new('B') }

    before do
      game.set_board_state('k7/8/8/5n2/8/3B4/4P3/KR6 w - - 0 1')
    end

    it 'correctly reports true when sending #slides? query' do
      expect(white_b.slides?).to be true
    end

    it 'correctly reports 3 moves when asked' do
      moves = white_b.moves(board, 'd3')
      expect(moves).to include(Move).exactly(3).times
    end
  end
end