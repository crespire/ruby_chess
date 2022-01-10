# frozen_string_literal: true

# spec/cell_spec.rb

require_relative '../lib/movement'
require_relative '../lib/board'

describe Movement do
  context 'on initialize' do
    let(:board) { Board.new }
    subject(:move_init) { described_class.new(board) }

    it 'stores a reference to the board properly' do
      board.make_board
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
    let(:board) { Board.new }

    context 'with a Rook as input' do
      subject(:rook_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'starting at b8, returns the correct list of available moves' do
          board.make_board('1r6/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('b8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a8 c8 d8 e8 f8 g8 h8])
        end

        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3r4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a4 b4 c4 e4 f4 g4 h4])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at a8, returns the correct list of available moves' do 
          board.make_board('r4b2/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8])
        end

        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3rb3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a4 b4 c4])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          board.make_board('r4B2/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8 xf8])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/8/3rB3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a4 b4 c4 xe4])
        end
      end

      context 'when there are multiple enemy pieces on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          board.make_board('r4BN1/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8 xf8])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/8/1RPrBN2/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[xc4 xe4])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including a capture' do
          board.make_board('8/8/8/8/2prBN2/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[xe4])
        end
      end
    end

    context 'with a King as input' do
      subject(:king_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'starting at a8, returns the correct list of available moves' do
          board.make_board('k7/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[b8])
        end

        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3k4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[c4 e4])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at a8, returns the correct list of available moves' do
          board.make_board('kn6/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[])
        end

        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/2nkp3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          board.make_board('kN6/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xb8])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/8/2PkP3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xc4 xe4])
        end
      end

      context 'where there are multiple enemy pieces on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          board.make_board('kNK5/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xb8])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/8/1PPkPP2/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xc4 xe4])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including a capture' do
          board.make_board('8/8/8/8/2pkP3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[xe4])
        end
      end
    end
  end

  context '#find_vertical_moves' do
    let(:board) { Board.new }

    context 'with a Rook as input' do
      subject(:rook_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'starting at a8, returns the correct list of available moves' do
          board.make_board('r7/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a1 a2 a3 a4 a5 a6 a7])
        end

        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3r4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d1 d2 d3 d5 d6 d7 d8])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at a8, returns the correct list of available moves' do 
          board.make_board('r7/8/8/b7/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a6 a7])
        end

        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/3k4/8/8/3r4/8/3n4/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d3 d5 d6])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          board.make_board('r7/8/8/8/B7/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a5 a6 a7 xa4])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/3N4/3r4/8/8/3B4 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d2 d3 xd1 xd5])
        end
      end

      context 'when there are multiple enemy pieces on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          board.make_board('r7/8/8/8/P7/N7/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a5 a6 a7 xa4])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/3P4/3N4/8/3r4/8/3P4/3B4 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d3 d5 xd2 xd6])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including a capture' do
          board.make_board('8/3B4/3p4/8/3r4/8/3N4/3B4 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d3 d5 xd2])
        end
      end
    end

    context 'with a King as input' do
      subject(:king_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'starting at a8, returns the correct list of available moves' do
          board.make_board('k7/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[a7])
        end

        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3k4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[d3 d5])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at a8, returns the correct list of available moves' do
          board.make_board('k7/n7/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[])
        end

        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/8/8/3p4/3k4/3q4/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          board.make_board('k7/N7/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xa7])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/3P4/3k4/3P4/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xd3 xd5])
        end
      end

      context 'where there are multiple enemy pieces on the path' do
        it 'starting at a8, returns the correct list of available moves including a capture' do
          board.make_board('k7/P7/P7/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xa7])
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/3P4/3P4/3k4/3P4/3P4/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xd3 xd5])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including a capture' do
          board.make_board('8/8/8/3p4/3k4/3P4/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[xd3])
        end
      end
    end
  end

  context '#find_diagonal_moves' do
    let(:board) { Board.new }

    context 'with a Bishop as input' do
      subject(:bishop_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'starting at c7, returns the correct list of available moves' do
          board.make_board('8/2b5/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('c7')
          eligible = %w[a5 b6 d8 b8 d6 e5 f4 g3 h2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end

        it 'starting at d4, returns the correct list of availalbe moves' do
          board.make_board('8/8/8/8/3b4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          eligible = %w[a7 b6 c5 h8 g7 f6 e5 c3 b2 a1 e3 f2 g1].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'starting at c7, returns the correct list of available moves' do 
          board.make_board('1n6/2b5/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('c7')
          eligible = %w[a5 b6 d8 d6 e5 f4 g3 h2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end

        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/8/1p3p1/8/3b4/8/1n7/8 b - - 1 2')
          cell = board.cell('d4')
          eligible = %w[c5 e5 c3 e3 f2 g1].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'starting at c7, returns the correct list of available moves including a capture' do 
          board.make_board('1N6/2b5/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('c7')
          eligible = %w[a5 b6 xb8 d8 d6 e5 f4 g3 h2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/1P7/8/3b4/8/1n3P2/8 b - - 1 2')
          cell = board.cell('d4')
          eligible = %w[c5 h8 xb6 g7 f6 e5 c3 e3 xf2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end
      end

      context 'when there are multiple enemy pieces on the path' do
        it 'starting at c7, returns the correct list of available moves including a capture' do
          board.make_board('1N6/2b5/8/4P3/5B2/8/8/8 b - - 1 2')
          cell = board.cell('c7')
          eligible = %w[a5 b6 xb8 d8 d6 xe5].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end

        it 'starting at d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/1P7/8/3b4/8/1n3P2/6N1 b - - 1 2')
          cell = board.cell('d4')
          eligible = %w[c5 h8 xb6 g7 f6 e5 c3 e3 xf2].sort
          expect(bishop_test.find_diagonal_moves(cell)).to eq(eligible)
        end
      end
    end
  end

  context '#find_knight_moves' do
    let(:board) { Board.new }
    subject(:knight_test) { described_class.new(board) }

    it 'returns nil when a given piece is not a knight' do
      board.make_board('b7/8/8/8/8/8/8/8 b - - 1 2')
      cell = board.cell('a8')
      expect(knight_test.find_knight_moves(cell)).to be_nil
    end

    it 'on an empty board starting at a8, returns the correct list of available moves' do
      board.make_board('n7/8/8/8/8/8/8/8 b - - 1 2')
      cell = board.cell('a8')
      eligible = %w[b6 c7].sort
      expect(knight_test.find_knight_moves(cell)).to eq(eligible)
    end

    it 'on an empty board starting at d4, returns the correct list of available moves' do
      board.make_board('8/8/8/8/3n4/8/8/8 b - - 1 2')
      cell = board.cell('d4')
      eligible = %w[c6 e6 f5 f3 e2 c2 b3 b5].sort
      expect(knight_test.find_knight_moves(cell)).to eq(eligible)
    end

    it 'on a board where there are other peices starting at d4, returns the correct list of available moves including possible captures' do
      board.make_board('8/8/2b1P3/8/3n4/5p2/2P5/8 b - - 1 2')
      cell = board.cell('d4')
      eligible = %w[xe6 f5 e2 xc2 b3 b5].sort
      expect(knight_test.find_knight_moves(cell)).to eq(eligible)
    end
  end

  context '#find_pawn_moves' do
    let(:board) { Board.new }
    subject(:pawn_test) { described_class.new(board) }

    context 'with a black Pawn' do
      context 'on an empty board' do
        it 'starting at c7, returns the correct list of available moves, including the double forward move' do
          board.make_board('8/2p5/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('c7')
          eligible = %w[c6 c5].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end

        it 'starting at c6, returns the correct list of available moves' do
          board.make_board('8/8/2p5/8/8/8/8/8 b - - 1 2')
          cell = board.cell('c6')
          eligible = %w[c5].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with a friendly' do
        it 'starting at c7, returns the correct list of available moves when full blocked' do
          board.make_board('8/2p5/2p5/8/8/8/8/8 b - - 1 2')
          cell = board.cell('c7')
          eligible = %w[].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end

        it 'starting at c7, returns the correct list of available moves when only one square blocked' do
          board.make_board('8/2p5/8/2p5/8/8/8/8 b - - 1 2')
          cell = board.cell('c7')
          eligible = %w[c6].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with other pieces' do
        context 'starting at c7' do
          it 'returns the correct list of available moves when fully blocked with a capture available' do
            board.make_board('8/2p5/1Pp5/8/8/8/8/8 b - - 1 2')
            cell = board.cell('c7')
            eligible = %w[xb6].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end

          it 'returns the correct list of available moves when only one sqaure is blocked and a capture is available' do
            board.make_board('8/2p5/3P4/2p5/8/8/8/8 b - - 1 2')
            cell = board.cell('c7')
            eligible = %w[c6 xd6].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end
        end

        context 'starting at c5' do
          it 'returns the correct list of available moves when fully blocked with a capture available' do
            board.make_board('8/8/8/2p5/1PpP4/8/8/8 b - - 1 2')
            cell = board.cell('c5')
            eligible = %w[xb4 xd4].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end
        end
      end
    end

    context 'with a white Pawn' do
      context 'on an empty board' do
        it 'starting at c2, returns the correct list of available moves, including the double forward move' do
          board.make_board('8/8/8/8/8/8/2P5/8 b - - 1 2')
          cell = board.cell('c2')
          eligible = %w[c3 c4].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end

        it 'starting at c3, returns the correct list of available moves' do
          board.make_board('8/8/8/8/8/2P5/8/8 b - - 1 2')
          cell = board.cell('c3')
          eligible = %w[c4].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with a friendly' do
        it 'starting at c2, returns the correct list of available moves when fully blocked' do
          board.make_board('8/8/8/8/8/2P5/2P5/8 b - - 1 2')
          cell = board.cell('c2')
          eligible = %w[].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end

        it 'starting at c2, returns the correct list of available moves when only one square blocked' do
          board.make_board('8/8/8/8/2P5/8/2P5/8 b - - 1 2')
          cell = board.cell('c2')
          eligible = %w[c3].sort
          expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with other pieces' do
        context 'starting at c3' do
          it 'returns the correct list of available moves when fully blocked with a capture available' do
            board.make_board('8/8/8/8/2Pp4/2P5/8/8 b - - 1 2')
            cell = board.cell('c3')
            eligible = %w[xd4].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end

          it 'returns the correct list of available moves when only one sqaure is blocked and a capture is available' do
            board.make_board('8/8/8/2N5/3p4/2P5/8/8 b - - 1 2')
            cell = board.cell('c3')
            eligible = %w[c4 xd4].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end
        end

        context 'starting at c4' do
          it 'returns the correct list of available moves when fully blocked with a capture available' do
            board.make_board('8/8/8/1pPp4/2P5/8/8/8 b - - 1 2')
            cell = board.cell('c4')
            eligible = %w[xb5 xd5].sort
            expect(pawn_test.find_pawn_moves(cell)).to eq(eligible)
          end
        end
      end
    end
  end

  xcontext '#find_king_moves' do
    let(:board) { Board.new }
    subject(:k_selfcheck_test) { described_class.new(board) }

    context 'on a board with an enemy Rook' do
      it 'starting on e6, returns the correct list of available moves that prevents a king from self-checking in the vertical axis' do
        board.make_board('8/8/4k3/8/8/8/5R2/8 b - - 1 2')
        cell = board.cell('e6')
        eligible = %w[e7 d7 d6 d5 e5].sort
        expect(k_selfcheck_test.find_king_moves(cell)).to eq(eligible)
      end

      xit 'starting on e6, returns the correct list of available moves that prevents a king from self-checking in the horizontal axis' do
        board.make_board('8/8/4k3/8/6R1/8/8/8 b - - 1 2')
        cell = board.cell('e6')
        eligible = %w[d6 f6 d7 e7 f7].sort
        expect(k_selfcheck_test.find_king_moves(cell)).to eq(eligible)
      end

      xit 'starting on e6, returns the correct list of available moves that prevents a king from self-checking in the diagonal axis' do
        board.make_board('8/8/4k3/8/8/5B2/8/8 b - - 1 2')
        cell = board.cell('e6')
        eligible = %w[d7 e7 f7 d6 f6 e5 f5].sort
        expect(k_selfcheck_test.find_king_moves(cell)).to eq(eligible)
      end

      xit 'starting on e6, returns correct list of available moves that prevents a king from self-checking in multiple axis' do
        board.make_board('8/8/4k3/8/5R2/5B2/8/8 b - - 1 2')
        cell = board.cell('e6')
        eligible = %w[d7 e7 d6 e5].sort
        expect(k_selfcheck_test.find_king_moves(cell)).to eq(eligible)
      end
    end
  end

  ##
  # Valid moves should combine all the axes that we make moves on. The test piece here should be a queen.
  context '#find_all_moves' do
    let(:board) { Board.new }
    subject(:moves_test) { described_class.new(board) }

    context 'with a Queen as input' do
      context 'on an empty board' do
        it 'starting at d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3q4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          eligible = %w[d8 d7 d6 d5 d3 d2 d1 a4 b4 c4 e4 f4 g4 h4 e5 f6 g7 h8 c3 b2 a1 c5 b6 a7 e3 f2 g1].sort
          expect(moves_test.find_knight_moves(cell)).to eq(eligible)
        end
      end

      xcontext 'on a board with mixed pieces in its path' do
        it 'starting at c5, returns the correct list of available moves including eligible captures' do
        end
      end
    end

    xcontext 'with a Knight as input' do
    end

    xcontext 'with a Pawn as input' do
    end

    xcontext 'with a King as input' do
    end
  end
end
