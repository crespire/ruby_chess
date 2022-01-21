# frozen_string_literal: true

# spec/piece_spec.rb

require_relative '../lib/move'
require_relative '../lib/chess'
require_relative '../lib/board'
require_relative '../lib/piece'
require_relative '../lib/pieces/all_pieces'

describe Move do
  let(:game) { Chess.new }
  let(:board) { game.board }

  context 'with a Knight at b8' do
    it 'builds all basic moves given a knight on the starting board' do
      knight = Piece::from_fen('n')
      moves = knight.moves(board, 'b8')
      expect(moves).to include(Move).exactly(8).times
    end

    it 'correctly reports three moves after removing dead moves' do
      knight = Piece::from_fen('n')
      moves = knight.moves(board, 'b8')
      expect(moves.reject(&:dead?)).to include(Move).exactly(2).times
    end
  end
end

