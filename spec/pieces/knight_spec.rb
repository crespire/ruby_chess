# frozen_string_literal: true

# spec/bishop_spec.rb

require_relative '../../lib/chess'
require_relative '../../lib/piece'
require_relative '../../lib/pieces/knight'

describe Knight do
  context 'with the given board' do
    let(:game) { Chess.new }
    let(:board) { game.board }
    let(:black_n) { Knight.new('n') }

    before do
      game.set_board_state('7k/2p1p3/1p3r2/3n4/5B2/2P5/8/K7 b - - 0 1')
    end

    it 'correctly reports 8 moves when send #all_paths' do
      moves = black_n.all_paths(board, 'd5')
      expect(moves).to include(Move).exactly(8).times
    end

    it 'correctly reports 4 moves when send #valid_paths' do
      moves = black_n.valid_paths(board, 'd5')
      expect(moves).to include(Move).exactly(4).times
    end

    it 'correctly includes valid moves when sent #moves' do
      moves = black_n.moves(board, 'd5')
      move_names = moves.map(&:name).sort
      expected = %w[f4 e3 c3 b4].sort
      expect(move_names).to eq(expected)
    end
  end
end