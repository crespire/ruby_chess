# frozen_string_literal: true

# spec/cell_spec.rb

require_relative '../lib/display'
require_relative '../lib/board'

describe Display do
  let(:board) { Board.new }
  subject(:display) { described_class.new(board) }

  context 'shows a provided board' do
    it 'displays a board' do
      board.make_board
      expect { display.show_board }.to output.to_stdout
    end
  end

  context 'when a piece is selected, and Display is provided a list of moves' do
    it 'displays the board, with captures and valid moves indicated' do
      board.make_board('8/8/3pp3/8/3n4/8/2P5/8 b - - 1 2')
      eligible = %w[xc2 e2 b3 b5 c6 f5 f3].sort
      display.show_board(moves: eligible)
      expect { display.show_board(moves: eligible) }.to output.to_stdout
    end

    it 'displays the board, with captures and valid moves indicated' do
      board.make_board('8/8/3PP3/8/3N4/8/2p5/8 b - - 1 2')
      eligible = %w[xc2 e2 b3 b5 c6 f5 f3].sort
      display.show_board(moves: eligible)
      expect { display.show_board(moves: eligible) }.to output.to_stdout
    end

    it 'displays the board, with captures and valid moves indicated' do
      board.make_board('8/8/4PP2/8/4N3/8/3p4/8 b - - 1 2')
      eligible = %w[xd2 f2 c3 c5 d6 g5 g3].sort
      display.show_board(moves: eligible)
      expect { display.show_board(moves: eligible) }.to output.to_stdout
    end

    it 'displays the board, with captures and valid moves indicated' do
      board.make_board('8/1k6/2p5/3q4/8/8/4R1B1/K7 b - - 0 1')
      eligible = %w[d8 d7 d6 d4 d3 d2 d1 e6 f7 g8 e5 f5 g5 h5 e4 f3 xg2 c4 b3 a2 a5 b5 c5].sort
      display.show_board(moves: eligible)
      expect { display.show_board(moves: eligible) }.to output.to_stdout
    end
  end
end