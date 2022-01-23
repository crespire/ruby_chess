# frozen_string_literal: true

# spec/queen_spec.rb

require_relative '../../lib/chess'
require_relative '../../lib/piece'
require_relative '../../lib/pieces/queen'

describe Queen do
  context 'with the given board' do
    let(:game) { Chess.new }
    let(:board) { game.board }
    let(:white_q) { Queen.new('Q') }

    before do
      game.set_board_state('k6q/1p6/8/6np/8/2P1QR2/4PP2/K1R5 w - - 0 1')
    end

    it 'correctly reports true when sending #slides? query' do
      expect(white_q.slides?).to be true
    end

    it 'correctly reports 5 moves when asked' do
      moves = white_q.moves(board, 'e3')
      expect(moves).to include(Move).exactly(5).times
    end
  end
end