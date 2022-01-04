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

  context '#horizontal_move' do
    let(:board) { Board.new }

    context 'with a Rook' do
      subject(:rook_test) { described_class.new(board) }

      context 'on an empty board' do
        it 'when Rook is on a8, provides the correct list of movement options' do
          board.make_board('r7/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.horizontal_move(cell)).to eq(%w[b8 c8 d8 e8 f8 g8 h8])
        end

        it 'when the Rook is on d4, provides the correct list of movement options' do
          board.make_board('8/8/8/8/3r4/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.horizontal_move(cell)).to eq(%w[a4 b4 c4 e4 f4 g4 h4])
        end
      end

      context 'where there is a friendly piece on the path' do
        it 'when the Rook starts on a8, returns the correct list of movement options' do 
          board.make_board('r4b2/8/8/8/8/8/8/8 b - - 1 2')
          cell = board.cell('a8')
          expect(rook_test.horizontal_move(cell)).to eq(%w[b8 c8 d8 e8])
        end
  
        it 'when the Rook is on d4, provides the correct list of movement options' do
          board.make_board('8/8/8/8/3rb3/8/8/8 b - - 1 2')
          cell = board.cell('d4')
          expect(rook_test.horizontal_move(cell)).to eq(%w[a4 b4 c4])
        end
      end
  
      context 'where there is an enemy piece on the path' do
        xit 'when the Rook is on a8, returns the correct list of movement options including a capture' do
        end
  
        xit 'when the Rook is on d4, provides the correct list of movement options' do
        end
      end
    end

  context 'with a King' do
    subject(:king_test) { described_class.new(board) }

    context 'on an empty board' do
      it 'when King is on a8, provides the correct list of movement options' do
        board.make_board('k7/8/8/8/8/8/8/8 b - - 1 2')
        cell = board.cell('a8')
        expect(king_test.horizontal_move(cell)).to eq(%w[b8])
      end

      it 'when the King is on d4, provides the correct list of movement options' do
        board.make_board('8/8/8/8/3k4/8/8/8 b - - 1 2')
        cell = board.cell('d4')
        expect(king_test.horizontal_move(cell)).to eq(%w[c4 e4])
      end
    end

    context 'where there is a friendly piece on the path' do
      xit 'when the King starts on a8, returns the correct list of movement options' do 
      end

      xit 'when the King is on d4, provides the correct list of movement options' do
      end
    end

    context 'where there is an enemy piece on the path' do
      xit 'when the King is on a8, returns the correct list of movement options including a capture' do
      end

      xit 'when the Rook is on d4, provides the correct list of movement options' do
      end
    end
  end

end

  context '#valid_moves' do
    context 'when provided a Cell with a Rook' do
      xit 'moves the piece in bounds as expected and returns true' do
      end
  
      xit 'does not move the piece and returns false' do
      end
    end
  end
end