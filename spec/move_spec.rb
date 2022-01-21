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
  let(:moves) { Array.new }

  context 'with a Knight at b8' do
    before do
      # I should use a mock here to test, because the actual Piece move will change
      # I plan to filter the move by psueo-legality, which would remove dead moves
      # as well as remove moves where the destination is a friendly/ie, the move is obstructed.
      # But those considerations are implemented in each piece.
      # To that end, I'm going to use Mocks here to faciliate testing, even though
      # the real objects exist already.

      # Knight offsets
      offsets = [[2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2], [1, 2]] #[file, rank] offset pairs
      offsets.each do |offset|
        moves << Move.new(board, 'b8', offset)
      end
    end
    it 'builds all basic moves given a knight on the starting board' do
      expect(moves).to include(Move).exactly(8).times
    end

    it 'correctly reports three moves after removing dead moves' do
      knight = Piece::from_fen('n')
      moves = knight.moves(board, 'b8')
      expect(moves.reject(&:dead?)).to include(Move).exactly(3).times
    end
  end

  context 'with a black pawn' do
    before do
      offsets = [[0, -1], [1, -1], [-1, -1]]
      offsets.each_with_index do |offset, i|
        moves << Move.new(board, 'd7', offset, (i.zero? ? 2 : 1))
      end
    end

    it 'with a black pawn on d7, builds all basic moves' do
      expect(moves).to include(Move).exactly(3).times
    end
  end

  context 'with a white pawn' do
    before do
      offsets = [[0, 1], [1, 1], [-1, 1]]
      offsets.each_with_index do |offset, i|
        moves << Move.new(board, 'h3', offset, (i.zero? ? 2 : 1))
      end
    end
    it 'with a white pawn on h3, builds all basic moves' do
      expect(moves).to include(Move).exactly(3).times
      expect(moves.reject(&:dead?)).to include(Move).exactly(2).times
    end
  end
  
    
end

