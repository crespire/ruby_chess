# frozen_string_literal: true

# spec/piece_spec.rb

require_relative '../lib/chess'
require_relative '../lib/piece'
require_relative '../lib/pieces/all_pieces'

describe Piece do
  context 'factory method ::from_fen' do
    it 'correctly makes the specified piece from a given FEN' do
      expect(described_class::from_fen('b')).to be_a(Bishop).and be_black
      expect(described_class::from_fen('K')).to be_a(King).and be_white
      expect { described_class::from_fen('M') }.to raise_error(ArgumentError)
    end
  end

  context 'color predicates #white? #black?' do 
    let(:white_pawn) { described_class::from_fen('P') }
    let(:black_pawn) { described_class::from_fen('p') }

    it 'correctly returns true and false for the colors given a few pieces' do
      expect(black_pawn).to be_a(Pawn)
      expect(black_pawn).to be_black
      expect(black_pawn).to_not be_white

      expect(white_pawn).to be_a(Pawn)
      expect(white_pawn).to be_white
      expect(white_pawn).to_not be_black
    end
  end

  context 'comparison method #==' do
    let(:white_pawn1) { described_class::from_fen('P') }
    let(:white_pawn2) { described_class::from_fen('P') }
    let(:black_pawn) { described_class::from_fen('p') }
    let(:white_knight) { described_class::from_fen('N') }

    it 'correctly returns true for two same pieces' do
      expect(white_pawn1 == white_pawn2).to be true
    end

    it 'correctly returns false for two same pieces but different colors' do
      expect(white_pawn1 == black_pawn).to be false
    end

    it 'correctly returns false for two different pieces, same color' do
      expect(white_pawn1 == white_knight).to be false
    end
  end

  context 'for each individiual piece' do
    let(:game) { Chess.new }
    let(:board) { game.board }

    context 'given a black knight with the given board' do
      let(:black_n) { Knight.new('n') }

      before do
        game.set_board_state('7k/2p1p3/1p3r2/3n4/5B2/2P5/8/K7 b - - 0 1')
      end

      it 'correctly reports 4 moves when asked' do
        moves = black_n.moves(board, 'd5')
        expect(moves.length).to eq(4)
      end
    end

    context 'given a white bishop with the given board' do
      let(:white_b) { Bishop.new('B') }

      before do
        game.set_board_state('k7/8/8/5n2/8/3B4/4P3/KR6 w - - 0 1')
      end

      it 'correctly reports 4 moves when asked' do
        moves = white_b.moves(board, 'd3')
        expect(moves.length).to eq(4)
      end
    end
  end

end
