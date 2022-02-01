# frozen_string_literal: true

# spec/ui_spec.rb

require_relative '../lib/ui'
require_relative '../lib/chess'

describe UI do
  let(:chess) { Chess.new }
  subject(:ui) { described_class.new(chess) }

  context 'Display functionality' do
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

  context 'User Input functionality' do
    context '#promp_pick_piece' do
      context 'given a board with white active' do
        before do
          chess.set_board_state('r1bqkb1r/pppp1ppp/2n2n2/4p3/4P3/2N2N2/PPPP1PPP/R1BQKB1R w KQkq - 4 4')
        end

        it 'returns the cell that a player has picked if validations pass' do
          input = 'c3'
          allow(ui).to receive(:gets).and_return(input)
          expect(ui.prompt_pick_piece).to be_a(Cell).and have_attributes(name: 'c3')
        end

        it 'reprompts when a player picks an out of bound destination' do
          input = 'c3'
          invalid_input = 'c9'
          allow(ui).to receive(:gets).and_return(invalid_input, input)
          expect { ui.prompt_pick_piece }.to output("White, please pick a piece using Chess notation: \nThis destination is out of bounds.\nWhite, please pick a piece using Chess notation: \n").to_stdout
          expect(ui.prompt_pick_piece).to be_a(Cell).and have_attributes(name: 'c3')
        end

        it 'reprompts when a player picks a non-owned piece' do
          input = 'c3'
          invalid_input = 'f6'
          allow(ui).to receive(:gets).and_return(invalid_input, input)
          expect { ui.prompt_pick_piece }.to output("White, please pick a piece using Chess notation: \nThis piece is not yours.\nWhite, please pick a piece using Chess notation: \n").to_stdout
          expect(ui.prompt_pick_piece).to be_a(Cell).and have_attributes(name: 'c3')
        end

        it 'reprompts when a player picks a piece with no moves' do
          input = 'c3'
          invalid_input = 'c1'
          allow(ui).to receive(:gets).and_return(invalid_input, input)
          expect { ui.prompt_pick_piece }.to output("White, please pick a piece using Chess notation: \nThis piece has no legal moves.\nWhite, please pick a piece using Chess notation: \n").to_stdout
          expect(ui.prompt_pick_piece).to be_a(Cell).and have_attributes(name: 'c3')
        end
      end
    end

    context '#prompt_pick_move' do
      context 'for a given board' do
        before do
          chess.set_board_state('r1bqkb1r/pppp1ppp/2n2n2/4p3/4P3/2N2N2/PPPP1PPP/R1BQKB1R w KQkq - 4 4')
        end

        it 'returns the string if a move is valid' do
          cell = chess.cell('d1')
          valid_moves = chess.move_manager.legal_moves(cell)
          input = 'e2'
          allow(ui).to receive(:gets).and_return(input)
          expect(ui.prompt_pick_move(cell, valid_moves)).to eq('e2')
        end

        it 'returns the string if a move is valid' do
          cell = chess.cell('f3')
          valid_moves = chess.move_manager.legal_moves(cell)
          input = 'g5'
          allow(ui).to receive(:gets).and_return(input)
          expect(ui.prompt_pick_move(cell, valid_moves)).to eq('g5')
        end

        it 'reprompts if a move is not valid' do
          cell = chess.cell('f3')
          valid_moves = chess.move_manager.legal_moves(cell)
          input = 'g5'
          invalid_input = 'e2'
          allow(ui).to receive(:gets).and_return(invalid_input, input)
          expect { ui.prompt_pick_move(cell, valid_moves) }.to output("Available moves for Nf3: d4, e5, g1, g5, h4\nPlease select a move: Not a valid selection.\nPlease select a move: ").to_stdout
          expect(ui.prompt_pick_move(cell, valid_moves)).to eq('g5')
        end
      end
    end
  end
end
