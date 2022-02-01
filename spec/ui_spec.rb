# frozen_string_literal: true

# spec/cell_spec.rb

require_relative '../lib/ui'
require_relative '../lib/chess'

describe UI do
  context 'ui functionality' do
    let(:chess) { Chess.new }
    subject(:ui) { described_class.new(chess) }

    context 'shows #show_board is called without a list of moves to highlight' do
      it 'displays a chess board' do
        expect { ui.show_board }.to output.to_stdout
      end
    end

    context 'when #show_board is provided a list of moves' do
      it 'displays the game board, with captures and valid moves indicated' do
        chess.set_board_state('8/8/3pp3/8/3n4/8/2P5/8 b - - 1 2')
        eligible = %w[c2 e2 b3 b5 c6 f5 f3].sort
        # ui.show_board(eligible)
        expect { ui.show_board(eligible) }.to output.to_stdout
      end

      it 'displays the game board, with captures and valid moves indicated' do
        chess.set_board_state('8/8/3PP3/8/3N4/8/2p5/8 b - - 1 2')
        eligible = %w[c2 e2 b3 b5 c6 f5 f3].sort
        # ui.show_board(eligible)
        expect { ui.show_board(eligible) }.to output.to_stdout
      end

      it 'displays the game board, with captures and valid moves indicated' do
        chess.set_board_state('8/8/4PP2/8/4N3/8/3p4/8 b - - 1 2')
        eligible = %w[d2 f2 c3 c5 d6 g5 g3].sort
        # ui.show_board(eligible)
        expect { ui.show_board(eligible) }.to output.to_stdout
      end

      it 'displays the game board, with captures and valid moves indicated' do
        chess.set_board_state('8/1k6/2p5/3q4/8/8/4R1B1/K7 b - - 0 1')
        eligible = %w[d8 d7 d6 d4 d3 d2 d1 e6 f7 g8 e5 f5 g5 h5 e4 f3 g2 c4 b3 a2 a5 b5 c5].sort
        # ui.show_board(eligible)
        expect { ui.show_board(eligible) }.to output.to_stdout
      end
    end

    context 'when sent #welcome' do
      it 'outputs the welcome message' do
        expect { ui.show_welcome }.to output("Welcome to Chess! This version of Chess is meant to be played by two players.\nAll the standard rules of Chess apply. Enjoy!\n").to_stdout
      end
    end

    context 'when sent #show_gameover with the appropriate conditions' do
      it 'correctly send the message that white won' do
        chess.set_board_state('7k/8/5BR1/6N1/8/8/8/3K4 b - - 50 1')
        expect { ui.show_gameover }.to output("Congratulations! White wins this game!\n").to_stdout
      end

      it 'correctly sends the message that black won' do
        chess.set_board_state('7k/8/8/8/1n6/2b5/8/K3r3 w - - 0 1')
        expect { ui.show_gameover }.to output("Congratulations! Black wins this game!\n").to_stdout
      end

      it 'correctly shows stalemate message when provided a stalemate' do
        chess.set_board_state('7k/8/8/8/2n1b3/8/3r4/K7 w - - 0 1')
        expect { ui.show_gameover }.to output("The game ended in a stalemate.\n").to_stdout
      end

      it 'correctly shows draw message when provided a board with two kings only' do
        chess.set_board_state('7k/8/8/8/8/8/8/K7 w - - 0 1')
        expect { ui.show_gameover }.to output("The game ended in a draw.\n").to_stdout
      end
    end
  end
end