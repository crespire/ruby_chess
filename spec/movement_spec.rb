# frozen_string_literal: true

# spec/cell_spec.rb

require_relative '../lib/movement'
require_relative '../lib/board'

describe Movement do
  context 'on initialize' do
    let(:board) { Board.new }
    subject(:move_init) { described_class.new(board.data) }

    it 'stores a reference to the board data properly' do
      board.make_board
      board_data = move_init.instance_variable_get(:@board)

      expect(board_data.flatten.length).to eq(64)
      board_data.each do |rank|
        rank.each do |cell|
          expect(cell).to be_a(Cell)
        end
      end
    end
  end

  context '#horizontal_move' do
    context 'when there are no other pieces on the board' do
      xit 'provides the correct list of movement options' do
      end
    end

    context 'when there is a friendly piece on the path' do
      xit 'returns the correct list of movement options' do 
      end
    end

    context 'when there is an enemy piece on the path' do
      xit 'returns the correct list of movement options including a capture' do
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