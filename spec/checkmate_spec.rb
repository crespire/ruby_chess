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

  context 'when provided a board in a checkmate situation' do
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
      expect(checkmate.stalemate?).to be true
    end
  end
end