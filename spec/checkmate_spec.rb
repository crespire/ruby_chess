# frozen_string_literal: true

# spec/checkmate_spec.rb

require_relative '../lib/checkmate'
require_relative '../lib/board'
require_relative '../lib/movement'

describe Checkmate do
  let(:board) { Board.new }
  
  context 'when provided a board in a check situation' do
    subject(:check) { described_class.new(board) }

    before do
      board.make_board('1nbqkbnr/rppp1pp1/p2N4/4p2p/4P2P/8/PPPP1PP1/R1BQKBNR b KQk - 1 5')
    end

    it 'returns true for the check' do
      expect(check.check?).to be true
    end

    it 'returns false for the checkmate' do
      expect(check.checkmate?).to be_falsey
    end
  end

  context 'when provided a board in a stalemate situation' do
    subject(:stale) { described_class.new(board) }

    before do
      board.make_board('K7/8/8/8/8/8/5Q2/7k b - - 1 1')
    end

    it 'returns false for check' do
      expect(stale.check?).to be_falsey
    end

    it 'returns false for checkmate' do
      expect(stale.checkmate?).to be_falsey
    end

    it 'returns true for stalemate' do
      expect(stale.stalemate?).to be true
    end
  end

  context 'when provided a board with black in a checkmate situation' do
    subject(:checkmate) { described_class.new(board) }

    before do
      board.make_board('4k3/1b2P3/4KN2/8/8/8/7p/8 b - - 1 1')
    end

    it 'returns true for checkmate' do
      expect(checkmate.checkmate?).to be true
    end

    it 'returns true for check' do
      expect(checkmate.check?).to be true
    end

    it 'returns true for stalemate' do
      expect(checkmate.stalemate?).to be false
    end
  end

  context 'when provided as board with white in a checkmate situation' do
    subject(:checkmate) { described_class.new(board) }

    before do
      board.make_board('rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3')
    end

    it 'returns true for checkmate' do
      expect(checkmate.checkmate?).to be true
    end

    it 'returns true for check' do
      expect(checkmate.check?).to be true
    end

    it 'returns true for stalemate' do
      expect(checkmate.stalemate?).to be false
    end
  end

  context 'when provided a board with white in a checkmate situation by a knight' do
    subject(:checkmate) { described_class.new(board) }

    before do
      board.make_board('r1b1k2r/ppppqppp/2n5/8/1PP2B2/3n1N2/1P1NPPPP/R2QKB1R w KQkq - 1 9')
    end

    it 'returns true for checkmate' do
      expect(checkmate.checkmate?).to be true
    end

    it 'returns true for check' do
      expect(checkmate.check?).to be true
    end

    it 'returns true for stalemate' do
      expect(checkmate.stalemate?).to be false
    end
  end
end