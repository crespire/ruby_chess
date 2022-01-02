# frozen_string_literal: true

# spec/board_spec.rb

require_relative '../lib/board'

describe Board do
  context 'on initialize' do
    subject(:init) { described_class.new }

    it 'creates an instance array to store data' do
      board = init.instance_variable_get(:@board)
      expect(board).to be_an(Array)
    end

    it 'array is 8x8' do
      board = init.instance_variable_get(:@board)
      expect(board.flatten.length).to eq(64)
    end

    it 'initializes to nil' do
      board = init.instance_variable_get(:@board)
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

      expect(active).to be_nil
      expect(half).to be_nil
      expect(full).to be_nil
      expect(castle).to be_nil
      expect(passant).to be_nil
    end
  end

  context '#make_board' do
    context 'when there are unrecognized characters in the notation' do
      subject(:fen_error) { described_class.new }

      it 'raises an ArgumentError' do
        input = 'rnbqkbnr/pp$ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2'
        expect { fen_error.make_board(input) }.to raise_error(ArgumentError)
      end
    end

    context 'generates the correct board representation for the given input' do
      subject(:fen_test) { described_class.new }

      it 'parses default starting position and generates the correct board' do
        fen_test.make_board
        board = fen_test.instance_variable_get(:@board)
        active = fen_test.instance_variable_get(:@active)
        full = fen_test.instance_variable_get(:@full)

        expect(board[0][0].name).to eq('a8')
        expect(board[0][0].content).to eq('r')
        expect(board[2][0].name).to eq('a6')
        expect(board[2][0].content).to be_nil
        expect(board[4][3].name).to eq('d4')
        expect(board[4][3].content).to be_nil
        expect(board[7][6].name).to eq('g1')
        expect(board[7][6].content).to eq('N')

        expect(full).to eq(1)
        expect(active).to eq('w')
      end

      it 'parses notation with pieces moved correctly' do
        input = 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2'
        fen_test.make_board(input)
        board = fen_test.instance_variable_get(:@board)
        active = fen_test.instance_variable_get(:@active)
        full = fen_test.instance_variable_get(:@full)

        expect(board[3][1].name).to eq('b5')
        expect(board[3][1]).to be_empty
        expect(board[3][2].name).to eq('c5')
        expect(board[3][2].content).to eq('p')
        expect(board[4][3].name).to eq('d4')
        expect(board[4][3]).to be_empty
        expect(board[4][4].name).to eq('e4')
        expect(board[4][4].content).to eq('P')
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
      it 'takes an array of 2 elements and returns the right chess notation' do
      end

      it 'returns nil if coordinates are out of range' do
      end
    end

    context '#std_chess_to_arr' do
      it 'takes a string of Chess notation and returns the right array coordinates' do
      end

      it 'returns nil if notation are out of range' do
      end
    end
  end
end
