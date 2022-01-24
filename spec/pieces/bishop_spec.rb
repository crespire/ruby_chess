# frozen_string_literal: true

# spec/bishop_spec.rb

require_relative '../../lib/chess'
require_relative '../../lib/piece'
require_relative '../../lib/pieces/bishop'

describe Bishop do
  it 'correctly reports true when sending #slides? query' do
    expect(Bishop.new('b').slides?).to be true
  end

  context 'with the given board' do
    let(:game) { Chess.new }
    let(:board) { game.board }
    let(:white_b) { Bishop.new('B') }

    before do
      game.set_board_state('k7/8/6q1/5n2/8/3B4/4P3/KR6 w - - 0 1')
    end

    it 'correctly reports 4 moves when sent #all_paths' do
      moves = white_b.all_paths(board, 'd3')
      expect(moves).to include(Move).exactly(4).times
    end

    it 'correctly includes all cells basic moves (all cells on all moves)' do
      moves = white_b.all_paths(board, 'd3')
      move_names = moves.map { |move| move.map(&:name) }.flatten.sort
      expected = %w[e4 f5 g6 h7 e2 f1 c2 b1 c4 b5 a6].sort
      expect(move_names).to eq(expected)
    end

    it 'correctly reports 3 moves when sent #valid_moves' do
      moves = white_b.valid_paths(board, 'd3')
      expect(moves).to include(Move).exactly(3).times
    end

    it 'correctly includes valid cells basic moves' do
      moves = white_b.moves(board, 'd3')
      move_names = moves.map(&:name).sort
      expected = %w[c2 a6 b5 c4 e4 f5].sort
      expect(move_names).to eq(expected)
    end
  end
end