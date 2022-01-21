# frozen_string_literal: true

# spec/piece_spec.rb

require_relative '../lib/piece'
require_relative '../lib/pieces/all_pieces'

describe Piece do
  context '::from_fen' do
    it 'correctly makes the specified piece from a given FEN' do
      expect(described_class::from_fen('b')).to be_a(Bishop).and be_black
      expect(described_class::from_fen('K')).to be_a(King).and be_white
      expect { described_class::from_fen('M') }.to raise_error(ArgumentError)
    end
  end
end