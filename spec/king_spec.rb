# frozen_string_literal: true

# spec/king_spec.rb

require_relative '../lib/chess'
require_relative '../lib/piece'
require_relative '../lib/pieces/king'

describe King do
  context 'with the given board' do
    let(:game) { Chess.new }
    let(:board) { game.board }
    let(:white_k) { King.new('K') }

    before do
      game.set_board_state('k6q/8/8/6n1/8/2PK4/4P3/2R5 w - - 0 1')
    end

    it 'correctly reports false when sending #slides? query' do
      expect(white_k.slides?).to be false
    end

    it 'correctly reports 6 moves when asked' do
      moves = white_k.moves(board, 'd3')
      expect(moves).to include(Move).exactly(6).times
    end
  end
end