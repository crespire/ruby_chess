# frozen_string_literal: true

# spec/cell_spec.rb

require_relative '../lib/movement'
require_relative '../lib/board'
require_relative '../lib/chess'

describe Movement do
  context 'on initialize' do
    let(:game) { Chess.new }
    subject(:move_init) { described_class.new(game) }

    it 'stores a reference to the board properly' do
      board_ref = move_init.instance_variable_get(:@board)

      expect(board_ref.data.flatten.length).to eq(64)
      board_ref.data.each do |rank|
        rank.each do |cell|
          expect(cell).to be_a(Cell)
        end
      end
    end
  end

  context '#find_horizontal_moves' do
    let(:game) { Chess.new }

    context 'with a Rook as input' do
      subject(:rook_test) { described_class.new(game) }

      context 'on an empty board' do
        it 'starting at b8, returns the correct list of available moves' do
          game.set_board_state('1r6/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('b8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a8 c8 d8 e8 f8 g8 h8])
        end

        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/8/8/8/3r4/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a4 b4 c4 e4 f4 g4 h4])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at a8, returns the correct list of available moves' do 
          game.set_board_state('r4b2/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8])
        end

        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/8/8/8/3rb3/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a4 b4 c4])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          game.set_board_state('r4B2/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8 xf8])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/8/8/8/3rB3/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a4 b4 c4 xe4])
        end
      end

      context 'when there are multiple enemy pieces on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          game.set_board_state('r4BN1/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8 xf8])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/8/8/8/1RPrBN2/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[xc4 xe4])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including a capture' do
          game.set_board_state('8/8/8/8/2prBN2/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[xe4])
        end
      end
    end

    context 'with a King as input' do
      subject(:king_test) { described_class.new(game) }

      context 'on an empty board' do
        it 'starting at a8, returns the correct list of available moves' do
          game.set_board_state('k7/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[b8])
        end

        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/8/8/8/3k4/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[c4 e4])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at a8, returns the correct list of available moves' do
          game.set_board_state('kn6/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[])
        end

        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/8/8/8/2nkp3/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          game.set_board_state('kN6/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xb8])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/8/8/8/2PkP3/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xc4 xe4])
        end
      end

      context 'where there are multiple enemy pieces on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          game.set_board_state('kNK5/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xb8])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/8/8/8/1PPkPP2/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xc4 xe4])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including a capture' do
          game.set_board_state('8/8/8/8/2pkP3/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xe4])
        end
      end
    end
  end

  context '#find_vertical_moves' do
    let(:game) { Chess.new }

    context 'with a Rook as input' do
      subject(:rook_test) { described_class.new(game) }

      context 'on an empty board' do
        it 'starting at a8, returns the correct list of available moves' do
          game.set_board_state('r7/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a1 a2 a3 a4 a5 a6 a7])
        end

        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/8/8/8/3r4/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d1 d2 d3 d5 d6 d7 d8])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at a8, returns the correct list of available moves' do 
          game.set_board_state('r7/8/8/b7/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a6 a7])
        end

        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/3k4/8/8/3r4/8/3n4/8 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d3 d5 d6])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          game.set_board_state('r7/8/8/8/B7/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a5 a6 a7 xa4])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/8/8/3N4/3r4/8/8/3B4 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d2 d3 xd1 xd5])
        end
      end

      context 'when there are multiple enemy pieces on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          game.set_board_state('r7/8/8/8/P7/N7/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a5 a6 a7 xa4])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/3P4/3N4/8/3r4/8/3P4/3B4 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d3 d5 xd2 xd6])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including a capture' do
          game.set_board_state('8/3B4/3p4/8/3r4/8/3N4/3B4 b - - 1 2')
          cell = game.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d3 d5 xd2])
        end
      end
    end

    context 'with a King as input' do
      subject(:king_test) { described_class.new(game) }

      context 'on an empty board' do
        it 'starting at a8, returns the correct list of available moves' do
          game.set_board_state('k7/8/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[a7])
        end

        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/8/8/8/3k4/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[d3 d5])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at a8, returns the correct list of available moves' do
          game.set_board_state('k7/n7/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[])
        end

        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/8/8/3p4/3k4/3q4/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          game.set_board_state('k7/N7/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xa7])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/8/8/3P4/3k4/3P4/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xd3 xd5])
        end
      end

      context 'where there are multiple enemy pieces on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          game.set_board_state('k7/P7/P7/8/8/8/8/8 b - - 1 2')
          cell = game.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xa7])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/8/3P4/3P4/3k4/3P4/3P4/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xd3 xd5])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including a capture' do
          game.set_board_state('8/8/8/3p4/3k4/3P4/8/8 b - - 1 2')
          cell = game.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xd3])
        end
      end
    end
  end

  context '#find_diagonal_moves' do
    let(:game) { Chess.new }

    context 'with a Bishop as input' do
      subject(:bishop_test) { described_class.new(game) }

      context 'on an empty board' do
        it 'starting at c7, returns the correct list of available moves' do
          game.set_board_state('8/2b5/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('c7')
          eligible = %w[a5 b6 d8 b8 d6 e5 f4 g3 h2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end

        it 'starting at d4, returns the correct list of availalbe moves' do
          game.set_board_state('8/8/8/8/3b4/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[a7 b6 c5 h8 g7 f6 e5 c3 b2 a1 e3 f2 g1].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at c7, returns the correct list of available moves' do 
          game.set_board_state('1n6/2b5/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('c7')
          eligible = %w[a5 b6 d8 d6 e5 f4 g3 h2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end

        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/8/1p3p1/8/3b4/8/1n6/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[c5 e5 c3 e3 f2 g1].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at c7, returns the correct list of available moves including a capture' do 
          game.set_board_state('1N6/2b5/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('c7')
          eligible = %w[a5 b6 xb8 d8 d6 e5 f4 g3 h2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/8/1P6/8/3b4/8/1n3P2/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[c5 h8 xb6 g7 f6 e5 c3 e3 xf2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end
      end

      context 'when there are multiple enemy pieces on the path' do
        it 'starting at c7, returns the correct list of available moves including a capture' do
          game.set_board_state('1N6/2b5/8/4P3/5B2/8/8/8 b - - 1 2')
          cell = game.cell('c7')
          eligible = %w[a5 b6 xb8 d8 d6 xe5].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          game.set_board_state('8/8/1P6/8/3b4/8/1n3P2/6N1 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[c5 h8 xb6 g7 f6 e5 c3 e3 xf2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end
      end
    end
  end

  context '#find_knight_moves' do
    let(:game) { Chess.new }
    subject(:knight_test) { described_class.new(game) }

    it 'returns nil when a given piece is not a knight' do
      game.set_board_state('b7/8/8/8/8/8/8/8 b - - 1 2')
      cell = game.cell('a8')
      expect(knight_test.find_knight_moves(cell)).to eq([])
    end

    it 'on an empty game starting at a8, returns the correct list of available moves' do
      game.set_board_state('n7/8/8/8/8/8/8/8 b - - 1 2')
      cell = game.cell('a8')
      eligible = %w[b6 c7].sort
      expect(knight_test.find_knight_moves(cell)).to eq(eligible)
    end

    it 'on an empty game starting at d4, returns the correct list of available moves' do
      game.set_board_state('8/8/8/8/3n4/8/8/8 b - - 1 2')
      cell = game.cell('d4')
      eligible = %w[c6 e6 f5 f3 e2 c2 b3 b5].sort
      expect(knight_test.find_knight_moves(cell)).to eq(eligible)
    end

    it 'on a board where there are other peices starting at d4, returns the correct list of available moves including possible captures' do
      game.set_board_state('8/8/2b1P3/8/3n4/5p2/2P5/8 b - - 1 2')
      cell = game.cell('d4')
      eligible = %w[xe6 f5 e2 xc2 b3 b5].sort
      expect(knight_test.find_knight_moves(cell)).to eq(eligible)
    end
  end

  context '#find_pawn_moves' do
    let(:game) { Chess.new }
    subject(:pawn_test) { described_class.new(game) }

    context 'with a black Pawn' do
      context 'on an empty board' do
        it 'starting at c7, returns the correct list of available moves, including the double forward move' do
          game.set_board_state('8/2p5/8/8/8/8/8/8 b - - 1 2')
          cell = game.cell('c7')
          eligible = %w[c6 c5].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end

        it 'starting at c6, returns the correct list of available moves' do
          game.set_board_state('8/8/2p5/8/8/8/8/8 b - - 1 2')
          cell = game.cell('c6')
          eligible = %w[c5].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with a friendly' do
        it 'starting at c7, returns the correct list of available moves when full blocked' do
          game.set_board_state('8/2p5/2p5/8/8/8/8/8 b - - 1 2')
          cell = game.cell('c7')
          eligible = %w[].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end

        it 'starting at c7, returns the correct list of available moves when only one square blocked' do
          game.set_board_state('8/2p5/8/2p5/8/8/8/8 b - - 1 2')
          cell = game.cell('c7')
          eligible = %w[c6].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with other pieces' do
        context 'starting at c7' do
          it 'returns the correct list of available moves when fully blocked with a capture available' do
            game.set_board_state('8/2p5/1Pp5/8/8/8/8/8 b - - 1 2')
            cell = game.cell('c7')
            eligible = %w[xb6].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end

          it 'returns the correct list of available moves when only one sqaure is blocked and a capture is available' do
            game.set_board_state('8/2p5/3P4/2p5/8/8/8/8 b - - 1 2')
            cell = game.cell('c7')
            eligible = %w[c6 xd6].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end
        end

        context 'starting at c5' do
          it 'returns the correct list of available moves when fully blocked with a capture available' do
            game.set_board_state('8/8/8/2p5/1PpP4/8/8/8 b - - 1 2')
            cell = game.cell('c5')
            eligible = %w[xb4 xd4].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end
        end
      end
    end

    context 'with a white Pawn' do
      context 'on an empty board' do
        it 'starting at c2, returns the correct list of available moves, including the double forward move' do
          game.set_board_state('k7/8/8/8/8/8/2P5/K7 w - - 1 2')
          cell = game.cell('c2')
          eligible = %w[c3 c4].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end

        it 'starting at c3, returns the correct list of available moves' do
          game.set_board_state('k7/8/8/8/8/2P5/8/K7 w - - 1 2')
          cell = game.cell('c3')
          eligible = %w[c4].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with a friendly' do
        it 'starting at c2, returns the correct list of available moves when fully blocked' do
          game.set_board_state('8/8/8/8/8/2P5/2P5/8 w - - 1 2')
          cell = game.cell('c2')
          eligible = %w[].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end

        it 'starting at c2, returns the correct list of available moves when only one square blocked' do
          game.set_board_state('8/8/8/8/2P5/8/2P5/8 w - - 1 2')
          cell = game.cell('c2')
          eligible = %w[c3].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with other pieces' do
        context 'starting at c3' do
          it 'returns the correct list of available moves when fully blocked with a capture available' do
            game.set_board_state('8/8/8/8/2Pp4/2P5/8/8 w - - 1 2')
            cell = game.cell('c3')
            eligible = %w[xd4].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end

          it 'returns the correct list of available moves when only one sqaure is blocked and a capture is available' do
            game.set_board_state('8/8/8/2N5/3p4/2P5/8/8 w - - 1 2')
            cell = game.cell('c3')
            eligible = %w[c4 xd4].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end
        end

        context 'starting at c4' do
          it 'returns the correct list of available moves when fully blocked with a capture available' do
            game.set_board_state('8/8/8/1pPp4/2P5/8/8/8 w - - 1 2')
            cell = game.cell('c4')
            eligible = %w[xb5 xd5].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end
        end
      end
    end

    context 'when given a pawn with an available passant capture' do
      it 'correctly shows the passant capture availabilty for a black pawn' do
        game.set_board_state('k7/7p/8/8/6pP/8/8/K7 b - h3 0 1')
        cell = game.cell('g4')
        eligible = %w[g3 xh3].sort
        expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
      end

      it 'correctly shows the passant capture availability for a white pawn' do
        game.set_board_state('k7/8/8/3Pp3/6pP/8/8/K7 w - e6 0 2')
        cell = game.cell('d5')
        eligible = %w[d6 xe6].sort
        expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
      end
    end
  end

  context '#find_all_moves' do
    let(:game) { Chess.new }
    subject(:moves_test) { described_class.new(game) }

    context 'with a Queen as input' do
      context 'on an empty board' do
        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('8/8/8/8/3q4/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[d8 d7 d6 d5 d3 d2 d1 a4 b4 c4 e4 f4 g4 h4 e5 f6 g7 h8 c3 b2 a1 c5 b6 a7 e3 f2 g1].sort
          expect(moves_test.find_all_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with mixed pieces in its path' do
        it 'starting at d4, returns the correct list of available moves including eligible captures' do
          game.set_board_state('8/3p4/8/8/3qn3/8/3P1P2/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[d6 d5 d3 xd2 a4 b4 c4 e5 f6 g7 h8 c3 b2 a1 c5 b6 a7 e3 xf2].sort
          expect(moves_test.find_all_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'with a Knight as input' do
      context 'on an empty board' do
        it 'starting at b6, returns the correct list of available moves' do
          game.set_board_state('8/8/1n6/8/8/8/8/8 b - - 1 2')
          cell = game.cell('b6')
          eligible = %w[a8 c8 d7 d5 c4 a4].sort
          expect(moves_test.find_all_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with mixed pieces in its path' do
        it 'starting at d4, returns the correct list of available moves including eligible captures' do
          game.set_board_state('8/8/3pp3/8/3n4/8/2P5/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[xc2 e2 b3 b5 c6 f5 f3].sort
          expect(moves_test.find_all_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'with a Pawn as input' do
      context 'when the Pawn is black' do
        context 'on an empty board' do
          it 'starting at c7, returns the correct list of available moves, including the double forward move' do
            game.set_board_state('8/2p5/8/8/8/8/8/8 b - - 1 2')
            cell = game.cell('c7')
            eligible = %w[c6 c5].sort
            expect(moves_test.find_all_moves(cell)).to eq(eligible)
          end
        end

        context 'on a board with other pieces' do
          it 'starting at c7, returns the correct list of available moves when only one sqaure is blocked and a capture is available' do
            game.set_board_state('8/2p5/3P4/2p5/8/8/8/8 b - - 1 2')
            cell = game.cell('c7')
            eligible = %w[c6 xd6].sort
            expect(moves_test.find_all_moves(cell)).to eq(eligible)
          end
        end
      end

      context 'when the Pawn is white' do
        context 'on an empty board' do
          it 'starting at c2, returns the correct list of available moves, including the double forward move' do
            game.set_board_state('8/8/8/8/8/8/2P5/8 w - - 1 2')
            cell = game.cell('c2')
            eligible = %w[c3 c4].sort
            expect(moves_test.find_all_moves(cell)).to eq(eligible)
          end
        end

        context 'on a board with other pieces' do
          it 'starting at c3, returns the correct list of available moves when only one sqaure is blocked and a capture is available' do
            game.set_board_state('8/8/8/2N5/3p4/2P5/8/8 w - - 1 2')
            cell = game.cell('c3')
            eligible = %w[c4 xd4].sort
            expect(moves_test.find_all_moves(cell)).to eq(eligible)
          end
        end
      end
    end

    context 'with a King as input' do
      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including a capture' do
          game.set_board_state('8/8/8/8/2pkP3/2N5/8/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[c5 d5 e5 xe4 xc3 d3 e3].sort
          expect(moves_test.find_all_moves(cell)).to eq(eligible)
        end
      end
    end
  end

  context '#find_king_moves' do
    let(:game) { Chess.new }
    subject(:k_selfcheck_test) { described_class.new(game) }

    context 'on a board with an enemy Rook' do
      it 'starting on e6, returns the correct list of available moves that prevents a king from self-checking in the vertical axis' do
        game.set_board_state('8/8/4k3/8/8/8/5R2/K7 b - - 1 2')
        cell = game.cell('e6')
        eligible = %w[e7 d7 d6 d5 e5].sort
        expect(k_selfcheck_test.find_king_moves(cell)).to eq(eligible)
      end

      it 'starting on e6, returns the correct list of available moves that prevents a king from self-checking in the horizontal axis' do
        game.set_board_state('8/8/4k3/6R1/8/8/8/8 b - - 1 2')
        cell = game.cell('e6')
        eligible = %w[d6 f6 d7 e7 f7].sort
        expect(k_selfcheck_test.find_king_moves(cell)).to eq(eligible)
      end

      it 'starting on e6, returns the correct list of available moves that prevents a king from self-checking in the diagonal axis' do
        game.set_board_state('8/8/4k3/8/8/5B2/8/8 b - - 1 2')
        cell = game.cell('e6')
        eligible = %w[d7 e7 f7 d6 f6 e5 f5].sort
        expect(k_selfcheck_test.find_king_moves(cell)).to eq(eligible)
      end

      it 'starting on e6, returns correct list of available moves that prevents a king from self-checking in multiple axis' do
        game.set_board_state('8/8/4k3/8/5R2/5B2/8/8 b - - 1 2')
        cell = game.cell('e6')
        eligible = %w[d7 e7 d6 e5].sort
        expect(k_selfcheck_test.find_king_moves(cell)).to eq(eligible)
      end
    end
  end

  context '#valid_moves' do
    let(:game) { Chess.new }
    subject(:valid_moves_test) { described_class.new(game) }

    context 'when provided a Knight' do
      context 'with other pieces on the board' do
        it 'correctly shows moves' do
          game.set_board_state('8/8/8/4k3/4r3/8/4N3/K7 w - - 0 1')
          cell = game.cell('e2')
          eligible = %w[c1 c3 d4 f4 g3 g1].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a Queen' do
      context 'on an empty board' do
        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('k7/8/8/8/3q4/8/8/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[d8 d7 d6 d5 d3 d2 d1 a4 b4 c4 e4 f4 g4 h4 e5 f6 g7 h8 c3 b2 a1 c5 b6 a7 e3 f2 g1].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with mixed pieces in its path' do
        it 'starting at d4, returns the correct list of available moves including eligible captures' do
          game.set_board_state('k7/3p4/8/8/3qn3/8/3P1P2/7K b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[d6 d5 d3 xd2 a4 b4 c4 e5 f6 g7 h8 c3 b2 a1 c5 b6 a7 e3 xf2].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a King' do
      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including two capture' do
          game.set_board_state('8/8/8/8/2pkP3/2N5/8/7K b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[c5 e5 xc3 d3 e3].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end
      end

      context 'when there are a limited set of moves' do
        it 'correctly shows moves that prevent self-checking' do
          game.set_board_state('8/8/8/2k5/3R4/2B5/8/4K3 b - - 1 2')
          cell = game.cell('c5')
          eligible = %w[b6 c6 b5].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end

        it 'correctly shows moves that prevent self-checking' do
          game.set_board_state('8/8/8/8/2pkP3/3B4/8/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[c3 xd3 e3 c5 e5].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end

        it 'correctly shows moves that would get out of a check' do
          game.set_board_state('k1q5/8/3r4/8/8/8/3K4/8 w - - 0 1')
          cell = game.cell('d2')
          eligible = %w[e1 e2 e3].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a Knight piece preventing a check' do
      context 'with other pieces on the board in a position to check' do
        it 'correctly shows 0 moves as any move would result in a self-check' do
          game.set_board_state('8/8/8/4k3/4n3/8/4R3/K7 b - - 0 1')
          cell = game.cell('e4')
          eligible = %w[]
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a Rook piece preventing a check' do
      context 'with other pieces on the board in a position to check' do
        it 'correctly shows only 2 moves as any other moves would result in a self-check' do
          game.set_board_state('8/8/8/4k3/4r3/8/4R3/K7 b - - 0 1')
          cell = game.cell('e4')
          eligible = %w[e3 xe2].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end

        it 'correctly shows only 3 moves as any other moves would result in a self-check' do
          game.set_board_state('8/8/4k3/4r3/8/8/4R3/K7 b - - 0 1')
          cell = game.cell('e5')
          eligible = %w[e4 e3 xe2].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a Queen piece preventing a check' do
      context 'with other pieces on the board in a position to check' do
        it 'correctly shows 0 moves as black should move the king to prevent a check-mate' do
          game.set_board_state('8/1k6/2q5/2N5/8/8/4R1B1/K7 b - - 0 1')
          cell = game.cell('c6')
          eligible = %w[]
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end

        it 'correctly shows only 2 moves as any other moves would result in a self-check' do
          game.set_board_state('8/8/8/3k4/4q3/8/6Q1/K7 b - - 0 1')
          cell = game.cell('e4')
          eligible = %w[f3 xg2].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end

        it 'correctly shows only 4 moves as any other moves would result in a self-check' do
          game.set_board_state('8/1k6/2q5/8/8/8/4R1B1/K7 b - - 0 1')
          cell = game.cell('c6')
          eligible = %w[d5 e4 f3 xg2].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end

        it 'correctly shows all moves as another friendly piece can prevent a self-check' do
          game.set_board_state('8/1k6/2p5/3q4/8/8/4R1B1/K7 b - - 0 1')
          cell = game.cell('d5')
          eligible = %w[d8 d7 d6 d4 d3 d2 d1 e6 f7 g8 e5 f5 g5 h5 e4 f3 xg2 c4 b3 a2 a5 b5 c5].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end

        it 'correctly shows all moves as another friendly piece can prevent a self-check' do
          game.set_board_state('8/1k6/2p5/8/8/5q2/4R1B1/K7 b - - 0 1')
          cell = game.cell('f3')
          eligible = %w[f1 f2 f4 f5 f6 f7 f8 a3 b3 c3 d3 e3 g3 h3 xe2 xg2 e4 d5 g4 h5].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end

        it 'correctly shows all moves as another friendly piece can prevent a self-check' do
          game.set_board_state('8/1k6/8/3p4/8/5q2/4R1B1/K7 b - - 0 1')
          cell = game.cell('f3')
          eligible = %w[f1 f2 f4 f5 f6 f7 f8 a3 b3 c3 d3 e3 g3 h3 xe2 xg2 e4 g4 h5].sort
          expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a black King in a check situation' do
      before do
        game.set_board_state('2Q3k1/6pp/5r1q/6N1/1P5P/6P1/5P2/6K1 b - - 0 1')
      end

      it 'when selecting the friendly Rook, correctly shows only one blocking move to prevent a check' do
        cell = game.cell('f6')
        eligible = %w[f8]
        expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
      end

      it 'when selecting the King, correctly shows only one blocking move to prevent a check' do
        cell = game.cell('g8')
        eligible = %w[]
        expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
      end

      it 'when selecting a friendly pawn, correctly shows no available moves' do
        cell = game.cell('g7')
        eligible = %w[]
        expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a black King in check by a white knight on d6' do
      before do
        game.set_board_state('1nbqkbnr/rppp1pp1/p2N4/4p2p/4P2P/8/PPPP1PP1/R1BQKBNR b KQk - 1 5')
      end

      it 'when selecting the King, correctly shows only one move' do
        cell = game.cell('e8')
        eligible = %w[e7]
        expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
      end

      it 'when selecting the pawn, correctly shows only one move' do
        cell = game.cell('c7')
        eligible = %w[xd6]
        expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
      end

      it 'when selecting the Bishop, correctly shows only one move' do
        cell = game.cell('f8')
        eligible = %w[xd6]
        expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a white King in checkmate, there should be no legal moves' do
      it 'when selecting the pawn at e2, correctly shows no moves' do
        game.set_board_state('r1b1k2r/ppppqppp/2n5/8/1PP2B2/3n1N2/1P1NPPPP/R2QKB1R w KQkq - 1 9')
        cell = game.cell('e2')
        expect(valid_moves_test.valid_moves(cell)).to eq([])
      end

      it 'when selecting the pawn at e3, correctly shows no legal moves' do
        game.set_board_state('r1b1k2r/ppppqppp/2n5/8/1PP2B2/3nPN2/1P1N1PPP/R2QKB1R w KQkq - 1 9')
        cell = game.cell('e3')
        expect(valid_moves_test.valid_moves(cell)).to eq([])
      end
    end

    context 'when provided a white pawn with an available passant capture during a check' do
      it 'correctly shows an available en passant to resolve the check' do
        game.set_board_state('r3k2r/pp1n1ppp/8/2pP1b2/2PK1PqP/1Q2P3/P5P1/2B2B1R w - c6 0 2')
        cell = game.cell('d5')
        eligible = %w[xc6]
        expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
      end

      it 'correctly shows an available move for the king in check' do
        game.set_board_state('r3k2r/pp1n1ppp/8/2pP1b2/2PK1PqP/1Q2P3/P5P1/2B2B1R w - c6 0 2')
        cell = game.cell('d4')
        eligible = %w[c3]
        expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a white pawn with an available passant capture during a check' do
      it 'shows the right moves' do
        game.set_board_state('r3k2r/pp1n1ppp/8/2pP1b2/2PK1PqP/1Q2P3/P5P1/2B2B1R w - c6 0 2')
        cell = game.cell('d5')
        eligible = %w[xc6]
        expect(valid_moves_test.valid_moves(cell)).to eq(eligible)
      end
    end
  end

  context 'testing with Perft boards from https://www.chessprogramming.org/Perft_Results' do
    let(:game) { Chess.new }
    subject(:valid_moves_test) { described_class.new(game) }

    it 'given position 2 without castle rights, should return the right amount of nodes' do
      game.set_board_state('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w - - 0 1')
      moves = 0
      game.board.data.each do |rank|
        rank.each do |cell|
          next if cell.empty? || cell.occupant.ord > 91

          legal = valid_moves_test.valid_moves(cell)
          moves += legal.length
        end
      end

      expect(moves).to eq(46) # missing one legal move, ba6 is a "threat" to the king's f1, but blocked.
    end

    it 'given position 3 without castle rights, should return the right amount of nodes' do
      game.set_board_state('8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - -  0 1')
      moves = 0
      game.board.data.each do |rank|
        rank.each do |cell|
          next if cell.empty? || cell.occupant.ord > 91

          legal = valid_moves_test.valid_moves(cell)
          moves += legal.length
        end
      end

      expect(moves).to eq(14)
    end

    it 'given position 4, should return the right amount of total moves' do
      game.set_board_state('r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1')
      moves = 0
      game.board.data.each do |rank|
        rank.each do |cell|
          next if cell.empty? || cell.occupant.ord > 91

          legal = valid_moves_test.valid_moves(cell)
          moves += legal.length
        end
      end

      expect(moves).to eq(6)
    end

    it 'given position 5 should return the right amount of total moves' do
      game.set_board_state('rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8')
      moves = 0
      game.board.data.each do |rank|
        rank.each do |cell|
          next if cell.empty? || cell.occupant.ord > 91

          legal = valid_moves_test.valid_moves(cell)
          moves += legal.length
        end
      end

      expect(moves).to eq(44)
    end
  end
end
