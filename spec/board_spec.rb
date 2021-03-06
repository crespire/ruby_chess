# frozen_string_literal: true

# spec/board_spec.rb

require_relative '../lib/chess'
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

    it 'initializes with Cells' do
      board = init.instance_variable_get(:@data)
      board.flatten.each do |cell|
        expect(cell).to be_a(Cell)
      end
    end

    it 'initializes with default board' do
      expect(init.cell('a8').piece).to be_a(Rook).and be_black
      expect(init.cell('d4')).to be_empty
      expect(init.cell('e1').piece).to be_a(King).and be_white
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
      test_cell = cells.cell('a8')
      test_cell2 = cells.cell('d4')

      expect(test_cell).to be_a(Cell).and have_attributes(name: 'a8')
      expect(test_cell2).to be_a(Cell).and have_attributes(name: 'd4')
    end

    it 'takes a string with optional offsets and returns the correct Cell object' do
      test_cell = cells.cell('a8', 0, -1)
      test_cell2 = cells.cell('d4', 1, 0)
      test_cell3 = cells.cell('d4', 5, 0)
      test_cell4 = cells.cell('d4', 4, 1)

      expect(test_cell).to be_a(Cell).and have_attributes(name: 'a7')
      expect(test_cell2).to be_a(Cell).and have_attributes(name: 'e4')
      expect(test_cell3).to be nil
      expect(test_cell4).to be_a(Cell).and have_attributes(name: 'h5')
    end
  end

  context '#find_piece' do
    subject(:find) { described_class.new }

    context 'from the starting position' do
      it 'correctly identifies the coordinates of the two White Bishops' do
        results = find.find_piece('B')
        expected = %w[c1 f1].sort
        expect(results).to include(Cell).twice
        expect(results.map(&:to_s)).to eq(expected)
      end

      it 'correctly identifies the coordinates of the two Black Bishops' do
        results = find.find_piece(Piece::from_fen('b'))
        expected = %w[c8 f8].sort
        expect(results).to include(Cell).twice
        expect(results.map(&:to_s)).to eq(expected)
      end

      it 'correctly identifies the coordinates of the eight Black pawns' do
        results = find.find_piece(Piece::from_fen('p'))
        expected = %w[a7 b7 c7 d7 e7 f7 g7 h7].sort
        expect(results).to include(Cell).exactly(8).times
        expect(results.map(&:to_s)).to eq(expected)
      end
    end
  end

  context 'King location methods' do
    subject(:kings) { described_class.new }

    it 'provides the correct locations for the Kings' do
      black = kings.bking
      white = kings.wking
      expect(black).to be_a(Cell).and have_attributes(name: 'e8')
      expect(white).to be_a(Cell).and have_attributes(name: 'e1')
    end
  end

  context '#to_fen' do
    it 'returns the correct FEN notation for the default board' do
      fen = described_class.new
      output = fen.to_fen
      expect(output).to eq('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR')
    end

    it 'returns the correct FEN for the specified board' do
      input = 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R'
      fen = described_class.new(input)
      output = fen.to_fen
      expect(output).to eq(input)
    end
  end

  context '#to_ascii' do
    it 'returns the correct ascii representation of board' do
      ascii = described_class.new
      expect { ascii.to_ascii }.to output("rnbqkbnr\npppppppp\n........\n........\n........\n........\nPPPPPPPP\nRNBQKBNR\n").to_stdout
    end

    it 'returns the correct represntation for specified board' do
      input = '8/p7/P7/8/8/3k4/3P4/3K4'
      ascii = described_class.new(input)
      expect { ascii.to_ascii }.to output("........\np.......\nP.......\n........\n........\n...k....\n...P....\n...K....\n").to_stdout
    end
  end

  context '#active_pieces' do
    it 'returns the correct active pieces for default board' do
      active = described_class.new
      expect(active.active_pieces).to eq(32)  
    end

    it 'returns the correct active pieces for the given board' do
      input = '8/6k1/8/8/8/8/8/3K4'
      active = described_class.new(input)
      expect(active.active_pieces).to eq(2)
    end
  end

  context '#update_loc' do
    subject(:move) { described_class.new }

    it 'moves an piece from the given origin to the given destination' do
      from = move.cell('a7')
      to = move.cell('a6')

      move.update_loc('a7', 'a6')
      expect(to.piece).to be_a(Pawn)
      expect(from.piece).to be_a(NilClass)
    end
  end
end
