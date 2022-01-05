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

  context '#find_horizontal_moves works' do
    let(:board) { Board.new }

    context 'with a Rook' do
      subject(:rook_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'and Rook starts on a8, returns the correct list of available moves' do
          board.make_board('r7/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8 f8 g8 h8])
        end

        it 'and the Rook starts on d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3r4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a4 b4 c4 e4 f4 g4 h4])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'and the Rook starts on a8, returns the correct list of available moves' do 
          board.make_board('r4b2/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8])
        end

        it 'and the Rook starts on d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3rb3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a4 b4 c4])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'and the Rook starts on a8, returns the correct list of available moves including a capture' do
          board.make_board('r4B2/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8 f8])
        end

        it 'and the Rook starts on d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/8/3rB3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[a4 b4 c4 e4])
        end
      end

      context 'when there are multiple enemy pieces on the path' do
        it 'and the Rook starts on a8, returns the correct list of available moves including a capture' do
          board.make_board('r4BN1/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[b8 c8 d8 e8 f8])
        end

        it 'and the Rook starts on d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/8/1RPrBN2/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[c4 e4])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'and the Rook starts on d4, returns the correct list of available moves including a capture' do
          board.make_board('8/8/8/8/2prBN2/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_horizontal_moves(cell)).to eq(%w[e4])
        end
      end
    end

    context 'with a King' do
      subject(:king_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'and King starts on a8, returns the correct list of available moves' do
          board.make_board('k7/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[b8])
        end

        it 'and the King starts on d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3k4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[c4 e4])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'and the King starts on a8, returns the correct list of available moves' do
          board.make_board('kn6/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[])
        end

        it 'and the King starts on d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/2nkp3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'and the King starts on a8, returns the correct list of available moves including a capture' do
          board.make_board('kN6/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[b8])
        end

        it 'and the King starts on d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/8/2PkP3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[c4 e4])
        end
      end

      context 'where there are multiple enemy pieces on the path' do
        it 'and the King starts on a8, returns the correct list of available moves including a capture' do
          board.make_board('kNK5/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[b8])
        end

        it 'and the King starts on d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/8/1PPkPP2/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[c4 e4])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'and the King starts on d4, returns the correct list of available moves including a capture' do
          board.make_board('8/8/8/8/2pkP3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_horizontal_moves(cell)).to eq(%w[e4])
        end
      end
    end
  end

  context '#find_vertical_moves works' do
    let(:board) { Board.new }

    context 'with a Rook' do
      subject(:rook_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'and Rook starts on a8, returns the correct list of available moves' do
          board.make_board('r7/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a1 a2 a3 a4 a5 a6 a7])
        end

        it 'and the Rook starts on d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3r4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d1 d2 d3 d5 d6 d7 d8])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'and the Rook starts on a8, returns the correct list of available moves' do 
          board.make_board('r7/8/8/b7/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a6 a7])
        end

        it 'and the Rook starts on d4, returns the correct list of available moves' do
          board.make_board('8/3k4/8/8/3r4/8/3n4/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d3 d5 d6])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'and the Rook starts on a8, returns the correct list of available moves including a capture' do
          board.make_board('r7/8/8/8/B7/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a4 a5 a6 a7])
        end

        it 'and the Rook starts on d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/3N4/3r4/8/8/3B4 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d1 d2 d3 d5])
        end
      end

      context 'when there are multiple enemy pieces on the path' do
        it 'and the Rook starts on a8, returns the correct list of available moves including a capture' do
          board.make_board('r7/8/8/8/P7/N7/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[a4 a5 a6 a7])
        end

        it 'and the Rook starts on d4, returns the correct list of available moves including both captures' do
          board.make_board('8/3P4/3N4/8/3r4/8/3P4/3B4 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d2 d3 d5 d6])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'and the Rook starts on d4, returns the correct list of available moves including a capture' do
          board.make_board('8/3B4/3p4/8/3r4/8/3N4/3B4 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.find_vertical_moves(cell)).to eq(%w[d2 d3 d5])
        end
      end
    end

    context 'with a King' do
      subject(:king_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'and King starts on a8, returns the correct list of available moves' do
          board.make_board('k7/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[a7])
        end

        it 'and the King starts on d4, returns the correct list of available moves' do
          board.make_board('8/8/8/8/3k4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[d3 d5])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'and the King starts on a8, returns the correct list of available moves' do
          board.make_board('k7/n7/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[])
        end

        it 'and the King starts on d4, returns the correct list of available moves' do
          board.make_board('8/8/8/3p4/3k4/3q4/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[])
        end
      end

      context 'where there is an enemy piece on the path' do
        it 'and the King starts on a8, returns the correct list of available moves including a capture' do
          board.make_board('k7/N7/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[a7])
        end

        it 'and the King starts on d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/8/3P4/3k4/3P4/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[d3 d5])
        end
      end

      context 'where there are multiple enemy pieces on the path' do
        it 'and the King starts on a8, returns the correct list of available moves including a capture' do
          board.make_board('k7/P7/P7/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[a7])
        end

        it 'and the King starts on d4, returns the correct list of available moves including both captures' do
          board.make_board('8/8/3P4/3P4/3k4/3P4/3P4/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[d3 d5])
        end
      end

      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'and the King starts on d4, returns the correct list of available moves including a capture' do
          board.make_board('8/8/8/3p4/3k4/3P4/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(king_test.find_vertical_moves(cell)).to eq(%w[d3])
        end
      end
    end
  end

  ##
  # Valid moves should combine all the axes that we make moves on. The test piece here should be a queen.
  context '#valid_moves works' do
    context 'with a Queen' do
      context 'on an empty board' do
        xit 'and the Queen starts on c5, returns the correct list of available moves' do
        end
      end

      context 'on a board with mixed pieces in its path' do
        xit 'and the Queen starts on c5, returns the correct list of available moves including eligible captures' do
        end
      end
    end
  end
end