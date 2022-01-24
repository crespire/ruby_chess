# frozen_string_literal: true

# spec/king_spec.rb

require_relative '../../lib/chess'
require_relative '../../lib/piece'
require_relative '../../lib/pieces/king'

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

    it 'correctly reports 8 moves when sent #all_paths' do
      moves = white_k.all_paths(board, 'd3')
      expect(moves).to include(Move).exactly(8).times
    end

    it 'correctly includes all cells basic moves (all cells on all moves)' do
      moves = white_k.all_paths(board, 'd3')
      move_names = moves.map { |move| move.map(&:name) }.flatten.sort
      expected = %w[d4 e4 e3 e2 d2 c2 c3 c4].sort
      expect(move_names).to eq(expected)
    end

    it 'correctly reports 6 moves when sent #valid_paths' do
      moves = white_k.valid_paths(board, 'd3')
      expect(moves).to include(Move).exactly(6).times
    end

    it 'correctly includes all valid moves when sent #moves' do
      moves = white_k.moves(board, 'd3')
      move_names = moves.map(&:name).sort
      expected = %w[d4 e4 e3 d2 c2 c4].sort
      expect(move_names).to eq(expected)
    end
  end
end