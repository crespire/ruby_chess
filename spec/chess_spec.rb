# frozen_string_literal: true

# spec/chess_spec.rb

require_relative '../lib/board'
require_relative '../lib/chess'

describe Chess do
  context 'initialize' do
    subject(:init) { described_class.new }

    it 'sets all game info values to default' do
      expect(init.active).to eq('w')
      expect(init.castle).to eq('KQkq')
      expect(init.passant).to eq('-')
      expect(init.half).to eq(0)
      expect(init.full).to eq(1)
      expect(init.ply).to eq(1)
    end
  end

  context '#set_board_state' do
    context 'when there are errors in the FEN notation provided' do
      subject(:fen_error) { described_class.new }

      it 'raises an ArgumentError when there are unrecognized characters in the notation' do
        expect { fen_error.set_board_state('rnbqkbnr/pp$ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2') }.to raise_error(ArgumentError)
      end

      it 'raises an ArgumentError when there are the incorrect number of information sections in the FEN' do
        expect { fen_error.set_board_state('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 1') }.to raise_error(ArgumentError)
      end

      it 'raises an ArgumentError when there are the wrong number of ranks in the FEN provided' do
        expect { fen_error.set_board_state('rnbqkbnr/pppppppp/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2') }.to raise_error(ArgumentError)
        expect { fen_error.set_board_state('rnbqkbnr/pppppppp/8/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2') }.to raise_error(ArgumentError)
      end
    end

    context 'generates the correct board representation' do
      subject(:fen_test) { described_class.new }

      it 'for the default starting position' do
        board = fen_test.instance_variable_get(:@board)
        active = fen_test.instance_variable_get(:@active)
        full = fen_test.instance_variable_get(:@full)
        half = fen_test.instance_variable_get(:@half)

        expect(board.data[0][0].name).to eq('a8')
        expect(board.data[0][0].occupant).to eq('r')
        expect(board.data[2][0].name).to eq('a6')
        expect(board.data[2][0].occupant).to be_nil
        expect(board.data[4][3].name).to eq('d4')
        expect(board.data[4][3].occupant).to be_nil
        expect(board.data[7][6].name).to eq('g1')
        expect(board.data[7][6].occupant).to eq('N')

        expect(full).to eq(1)
        expect(half).to eq(0)
        expect(active).to eq('w')
      end

      it 'for a board with pieces moved correctly' do
        input = 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2'
        fen_test.set_board_state(input)
        board = fen_test.instance_variable_get(:@board)
        active = fen_test.instance_variable_get(:@active)
        full = fen_test.instance_variable_get(:@full)

        expect(board.data[3][1].name).to eq('b5')
        expect(board.data[3][1]).to be_empty
        expect(board.data[3][2].name).to eq('c5')
        expect(board.data[3][2].occupant).to eq('p')
        expect(board.data[4][3].name).to eq('d4')
        expect(board.data[4][3]).to be_empty
        expect(board.data[4][4].name).to eq('e4')
        expect(board.data[4][4].occupant).to eq('P')
        expect(board.data[4][5].name).to eq('f4')
        expect(board.data[4][5]).to be_empty

        expect(full).to eq(2)
        expect(active).to eq('b')
      end
    end
  end

  context '#make_fen' do
    subject(:get_fen) { described_class.new }

    context 'on the starting position board' do
      it 'generates the right FEN notation for the given board' do
        fen = get_fen.make_fen
        expect(fen).to eq('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
      end
    end

    context 'on a board with moves made' do
      it 'generates the right FEN notation for the given board' do
        input = 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2'
        get_fen.set_board_state(input)
        fen = get_fen.make_fen
        expect(fen).to eq(input)
      end
    end
  end

  context '#move_piece' do
    subject(:chess) { described_class.new }

    it 'sends a message to move pieces to Board' do
      board = chess.instance_variable_get(:@board)
      
      expect(board).to receive(:update_loc)
      chess.move_piece('a7', 'a6')
    end

    context 'Given a sequence of moves' do
      subject(:move) { described_class.new }

      context 'on ply 1, when moving a starting white pawn' do
        it 'increments the ply counter' do
          expect { move.move_piece('a2', 'a4') }.to change { move.instance_variable_get(:@ply) }.by(1)
        end

        it 'does not increment the full move counter' do
          expect { move.move_piece('a2', 'a4') }.to_not(change { move.instance_variable_get(:@full) })
        end

        it 'resets the half move counter to 0' do
          expect { move.move_piece('a2', 'a4') }.to_not(change { move.instance_variable_get(:@half) })
        end

        it 'sets the active to black' do
          expect { move.move_piece('a2', 'a4') }.to change { move.instance_variable_get(:@active) }.to('b')
        end
      end

      context 'on ply 2, when moving a starting black pawn' do
        before do
          move.set_board_state('rnbqkbnr/pppppppp/8/8/7P/8/PPPPPPP1/RNBQKBNR b KQkq - 0 1')
        end

        it 'increments the ply counter' do
          expect { move.move_piece('a7', 'a6') }.to change { move.instance_variable_get(:@ply) }.by(1)
        end

        it 'increments the full move counter' do
          expect { move.move_piece('a7', 'a6') }.to change { move.instance_variable_get(:@full) }.by(1)
        end

        it 'resets the half move counter to 0' do
          expect { move.move_piece('a7', 'a6') }.to_not(change { move.instance_variable_get(:@half) })
        end

        it 'sets the active to white' do
          expect { move.move_piece('a7', 'a6') }.to change { move.instance_variable_get(:@active) }.to('w')
        end
      end

      context 'on ply 3, when moving a white knight' do
        before do
          move.set_board_state('rnbqkbnr/1ppppppp/p7/8/7P/8/PPPPPPP1/RNBQKBNR w KQkq - 0 2')
        end

        it 'increments the ply counter' do
          expect { move.move_piece('b1', 'c3') }.to change { move.instance_variable_get(:@ply) }.by(1)
        end

        it 'increments the half move counter by 1' do
          expect { move.move_piece('b1', 'c3') }.to change { move.instance_variable_get(:@half) }.by(1)
        end

        it 'does not increment the full move counter' do
          expect { move.move_piece('b1', 'c3') }.to_not(change { move.instance_variable_get(:@full) })
        end
      end

      context 'on ply 4, when moving a black rook' do
        before do
          move.set_board_state('rnbqkbnr/1ppppppp/p7/8/7P/2N5/PPPPPPP1/R1BQKBNR b KQkq - 1 2')
        end

        it 'increments the half move counter by 1' do
          expect { move.move_piece('a8', 'a7') }.to change { move.instance_variable_get(:@half) }.by(1)
        end

        it 'increments the full move counter' do
          expect { move.move_piece('a8', 'a7') }.to change { move.instance_variable_get(:@full) }.by(1)
        end
      end

      context 'on ply 5, when moving the white knight' do
        before do
          move.set_board_state('1nbqkbnr/rppppppp/p7/8/7P/2N5/PPPPPPP1/R1BQKBNR w KQk - 2 3')
        end

        it 'increments the half move counter by 1' do
          expect { move.move_piece('c3', 'b5') }.to change { move.instance_variable_get(:@half) }.by(1)
        end
      end

      context 'on ply 6' do
        before do
          move.set_board_state('1nbqkbnr/rppppppp/p7/1N6/7P/8/PPPPPPP1/R1BQKBNR b KQk - 3 3')
        end

        context 'when moving a black pawn to capture b5' do
          it 'resets the half move counter' do
            expect { move.move_piece('a6', 'b5') }.to change { move.instance_variable_get(:@half) }.to(0)
          end

          it 'increments the full move counter' do
            expect { move.move_piece('a6', 'b5') }.to change { move.instance_variable_get(:@full) }.by(1)
          end
        end

        context 'when moving a black pawn to h5' do
          it 'reests the half move counter' do
            expect { move.move_piece('h7', 'h5') }.to change { move.instance_variable_get(:@half) }.to(0)
          end

          it 'increments the full move counter' do
            expect { move.move_piece('a6', 'b5') }.to change { move.instance_variable_get(:@full) }.by(1)
          end
        end
      end

      context 'on the given board' do
        it 'resets the half move counter on a capture' do
          move.set_board_state('1nbqkbnr/rppp1pp1/p2N4/4p2p/4P2P/8/PPPP1PP1/R1BQKBNR b KQk - 1 5')
          expect { move.move_piece('f8', 'd6') }.to change { move.instance_variable_get(:@half) }.to(0)
        end
      end
    end
  end
end