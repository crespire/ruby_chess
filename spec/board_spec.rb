# frozen_string_literal: true

# spec/board_spec.rb

require_relative '../lib/board'

describe Board do
  context 'on initialize' do
    subject(:init) { described_class.new }

    it 'creates an instance array to store data' do
      board = init.instance_variable_get(:@data)
      expect(board).to be_an(Array)
    end

    it 'array is 8x8' do
      board = init.instance_variable_get(:@data)
      expect(board.flatten.length).to eq(64)
    end

    it 'initializes to nil' do
      board = init.instance_variable_get(:@data)
      board.flatten.each do |cell|
        expect(cell).to be_nil
      end
    end

    it 'initializes trackers and counters to nil' do
      active = init.instance_variable_get(:@active)
      half = init.instance_variable_get(:@half)
      full = init.instance_variable_get(:@full)
      castle = init.instance_variable_get(:@castle)
      passant = init.instance_variable_get(:@passant)
      ply = init.instance_variable_get(:@ply)

      expect(active).to be_nil
      expect(half).to be_nil
      expect(full).to be_nil
      expect(castle).to be_nil
      expect(passant).to be_nil
      expect(ply).to eq(0)
    end
  end

  context '#make_board' do
    context 'when there are errors in the FEN notation provided' do
      subject(:fen_error) { described_class.new }

      it 'raises an ArgumentError when there are unrecognized characters in the notation' do
        expect { fen_error.make_board('rnbqkbnr/pp$ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2') }.to raise_error(ArgumentError)
      end

      it 'raises an ArgumentError when there are the incorrect number of information sections in the FEN' do
        expect { fen_error.make_board('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 1') }.to raise_error(ArgumentError)
      end

      it 'raises an ArgumentError when there are the wrong number of ranks in the FEN provided' do
        expect { fen_error.make_board('rnbqkbnr/pppppppp/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2') }.to raise_error(ArgumentError)
        expect { fen_error.make_board('rnbqkbnr/pppppppp/8/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2') }.to raise_error(ArgumentError)
      end
    end

    context 'generates the correct board representation' do
      subject(:fen_test) { described_class.new }

      it 'for the default starting position' do
        fen_test.make_board
        board = fen_test.instance_variable_get(:@data)
        active = fen_test.instance_variable_get(:@active)
        full = fen_test.instance_variable_get(:@full)

        expect(board[0][0].name).to eq('a8')
        expect(board[0][0].occupant).to eq('r')
        expect(board[2][0].name).to eq('a6')
        expect(board[2][0].occupant).to be_nil
        expect(board[4][3].name).to eq('d4')
        expect(board[4][3].occupant).to be_nil
        expect(board[7][6].name).to eq('g1')
        expect(board[7][6].occupant).to eq('N')

        expect(full).to eq(1)
        expect(active).to eq('w')
      end

      it 'for a board with pieces moved correctly' do
        input = 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2'
        fen_test.make_board(input)
        board = fen_test.instance_variable_get(:@data)
        active = fen_test.instance_variable_get(:@active)
        full = fen_test.instance_variable_get(:@full)

        expect(board[3][1].name).to eq('b5')
        expect(board[3][1]).to be_empty
        expect(board[3][2].name).to eq('c5')
        expect(board[3][2].occupant).to eq('p')
        expect(board[4][3].name).to eq('d4')
        expect(board[4][3]).to be_empty
        expect(board[4][4].name).to eq('e4')
        expect(board[4][4].occupant).to eq('P')
        expect(board[4][5].name).to eq('f4')
        expect(board[4][5]).to be_empty

        expect(full).to eq(2)
        expect(active).to eq('b')
      end
    end
  end

  context '#make_fen' do
    subject(:get_fen) { described_class.new }

    context 'on the starting position board' do
      it 'generates the right FEN notation for the given board' do
        get_fen.make_board
        fen = get_fen.make_fen
        expect(fen).to eq('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
      end
    end

    context 'on a board with moves made' do
      it 'generates the right FEN notation for the given board' do
        input = 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2'
        get_fen.make_board(input)
        fen = get_fen.make_fen
        expect(fen).to eq(input)
      end
    end
  end

  context 'coordinates conversions' do
    context '#arr_to_std_chess' do
      subject(:coords) { described_class.new }

      it 'takes an array of 2 elements and returns the right chess notation' do
        expect(coords.arr_to_std_chess([0, 0])).to eq('a8')
        expect(coords.arr_to_std_chess([0, 1])).to eq('b8')
        expect(coords.arr_to_std_chess([4, 3])).to eq('d4')
        expect(coords.arr_to_std_chess([3, 3])).to eq('d5')
        expect(coords.arr_to_std_chess([4, 4])).to eq('e4')
        expect(coords.arr_to_std_chess([5, 2])).to eq('c3')
        expect(coords.arr_to_std_chess([7, 1])).to eq('b1')
        expect(coords.arr_to_std_chess([7, 7])).to eq('h1')
      end

      it 'returns nil if coordinates are out of range' do
        expect(coords.arr_to_std_chess([8, 8])).to be_nil
      end
    end

    context '#std_chess_to_arr' do
      subject(:coords) { described_class.new }

      it 'takes a string of Chess notation and returns the right array coordinates' do
        coords.make_board

        expect(coords.std_chess_to_arr('a8')).to eq([0, 0])
        expect(coords.std_chess_to_arr('b8')).to eq([0, 1])
        expect(coords.std_chess_to_arr('d4')).to eq([4, 3])
        expect(coords.std_chess_to_arr('d5')).to eq([3, 3])
        expect(coords.std_chess_to_arr('e4')).to eq([4, 4])
        expect(coords.std_chess_to_arr('c3')).to eq([5, 2])
        expect(coords.std_chess_to_arr('h1')).to eq([7, 7])
      end

      it 'returns nil if notation are out of range' do
        expect(coords.std_chess_to_arr('j9')).to be_nil
      end
    end
  end

  context '#cell' do
    subject(:cells) { described_class.new }

    it 'takes a string of Chess notation and returns the correct Cell object' do
      cells.make_board
      test_cell = cells.cell('a8')
      test_cell2 = cells.cell('d4')

      expect(test_cell).to have_attributes(name: 'a8')
      expect(test_cell2).to have_attributes(name: 'd4')
    end
  end

  context '#update_loc' do
    subject(:move) { described_class.new }

    it 'moves an occupant from the given origin to the given destination' do
      move.make_board
      from = move.cell('a7')
      to = move.cell('a6')

      expect { move.update_loc('a7', 'a6') }.to \
        change { to.occupant }.from(nil).to('p').and \
        change { from.occupant }.from('p').to(nil)
    end

    context 'on ply 1, when moving a starting white pawn' do
      before do
        move.make_board
      end

      it 'increments the ply counter' do
        expect { move.update_loc('a2', 'a4') }.to change { move.instance_variable_get(:@ply) }.by(1)
      end

      it 'does not increment the full move counter' do
        expect { move.update_loc('a2', 'a4') }.to_not(change { move.instance_variable_get(:@full) })
      end

      it 'resets the half move counter to 0' do
        expect { move.update_loc('a2', 'a4') }.to_not(change { move.instance_variable_get(:@half) })
      end

      it 'sets the active to black' do
        expect { move.update_loc('a2', 'a4') }.to change { move.instance_variable_get(:@active) }.to('b')
      end
    end

    context 'on ply 2, when moving a starting black pawn' do
      before do
        move.make_board('rnbqkbnr/pppppppp/8/8/7P/8/PPPPPPP1/RNBQKBNR b KQkq - 0 1')
      end

      it 'increments the ply counter' do
        expect { move.update_loc('a7', 'a6') }.to change { move.instance_variable_get(:@ply) }.by(1)
      end

      it 'increments the full move counter' do
        expect { move.update_loc('a7', 'a6') }.to change { move.instance_variable_get(:@full) }.by(1)
      end

      it 'resets the half move counter to 0' do
        expect { move.update_loc('a7', 'a6') }.to_not(change { move.instance_variable_get(:@half) })
      end

      it 'sets the active to white' do
        expect { move.update_loc('a7', 'a6') }.to change { move.instance_variable_get(:@active) }.to('w')
      end
    end

    context 'on ply 3, when moving a white knight' do
      before do
        move.make_board('rnbqkbnr/1ppppppp/p7/8/7P/8/PPPPPPP1/RNBQKBNR w KQkq - 0 2')
      end

      it 'increments the ply counter' do
        expect { move.update_loc('b1', 'c3') }.to change { move.instance_variable_get(:@ply) }.by(1)
      end

      it 'increments the half move counter by 1' do
        expect { move.update_loc('b1', 'c3') }.to change { move.instance_variable_get(:@half) }.by(1)
      end

      it 'does not increment the full move counter' do
        expect { move.update_loc('b1', 'c3') }.to_not(change { move.instance_variable_get(:@full) })
      end
    end

    context 'on ply 4, when moving a black rook' do
      before do
        move.make_board('rnbqkbnr/1ppppppp/p7/8/7P/2N5/PPPPPPP1/R1BQKBNR b KQkq - 1 2')
      end

      it 'increments the half move counter by 1' do
        expect { move.update_loc('a8', 'a7') }.to change { move.instance_variable_get(:@half) }.by(1)
      end

      it 'increments the full move counter' do
        expect { move.update_loc('a8', 'a7') }.to change { move.instance_variable_get(:@full) }.by(1)
      end
    end

    context 'on ply 5, when moving the white knight' do
      before do
        move.make_board('1nbqkbnr/rppppppp/p7/8/7P/2N5/PPPPPPP1/R1BQKBNR w KQk - 2 3')
      end

      it 'increments the half move counter by 1' do
        expect { move.update_loc('c3', 'b5') }.to change { move.instance_variable_get(:@half) }.by(1)
      end
    end

    context 'on ply 6' do
      before do
        move.make_board('1nbqkbnr/rppppppp/p7/1N6/7P/8/PPPPPPP1/R1BQKBNR b KQk - 3 3')
      end

      context 'when moving a black pawn to capture b5' do
        it 'resets the half move counter' do
          expect { move.update_loc('a6', 'b5') }.to change { move.instance_variable_get(:@half) }.to(0)
        end
        it 'increments the full move counter' do
          expect { move.update_loc('a6', 'b5') }.to change { move.instance_variable_get(:@full) }.by(1)
        end
      end

      context 'when moving a black pawn to h5' do
        it 'reests the half move counter' do
          expect { move.update_loc('h7', 'h5') }.to change { move.instance_variable_get(:@half) }.to(0)
        end

        it 'increments the full move counter' do
          expect { move.update_loc('a6', 'b5') }.to change { move.instance_variable_get(:@full) }.by(1)
        end
      end
    end

    context 'on the given board' do
      it 'resets the half move counter on a capture' do
        move.make_board('1nbqkbnr/rppp1pp1/p2N4/4p2p/4P2P/8/PPPP1PP1/R1BQKBNR b KQk - 1 5')
        expect { move.update_loc('f8', 'd6') }.to change { move.instance_variable_get(:@half) }.to(0)
      end
    end
  end

  context '#find_piece' do
    subject(:find) { described_class.new }

    context 'from the starting position' do
      before do
        find.make_board
      end

      it 'correctly identifies the coordinates of the two White Bishops' do
        results = find.find_piece('B')
        expected = %w[c1 f1].sort
        expect(results).to eq(expected)
      end

      it 'correctly identifies the coordinates of the two Black Bishops' do
        results = find.find_piece('b')
        expected = %w[c8 f8].sort
        expect(results).to eq(expected)
      end

      it 'correctly identifies the coordinates of the eight Black pawns' do
        results = find.find_piece('p')
        expected = %w[a7 b7 c7 d7 e7 f7 g7 h7].sort
        expect(results).to eq(expected)
      end
    end
  end

  context 'King location methods' do
    subject(:kings) { described_class.new }

    it 'provides the correct locations for the Kings' do
      kings.make_board
      black = kings.bking
      white = kings.wking
      expect(black).to eq('e8')
      expect(white).to eq('e1')
    end
  end
end
