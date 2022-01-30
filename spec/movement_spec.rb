# frozen_string_literal: true

# spec/cell_spec.rb

require_relative '../lib/movement'

describe Movement do
  context 'on initialize' do
    let(:game) { Chess.new }
    subject(:move_init) { described_class.new(game) }

    it 'stores a reference to the board properly' do
      board_ref = move_init.instance_variable_get(:@board)

      expect(board_ref.data.flatten.length).to eq(64)
      board_ref.data.each do |rank|
        rank.each do |cell|
          expect(cell).to be_a(Cell)
        end
      end
    end

    it 'stores a reference to the game' do
      game_ref = move_init.instance_variable_get(:@game)

      expect(game_ref).to be_a(Chess)
    end
  end

  context '#get_enemies' do
    context 'for given board #1' do
      let(:game) { Chess.new }
      subject(:get_enemies_test) { described_class.new(game) }

      before do
        game.set_board_state('8/8/8/8/2pkP3/8/4N3/7K b - - 1 2')
      end

      it 'returns the expected data structure' do
        expected = get_enemies_test.get_enemies(game.board.bking)
        expect(expected).to include(Array).exactly(2).times
        expect(expected[0]).to include(Cell).exactly(1).times
        expect(expected[1]).to include(Cell).exactly(2).times
      end
    end

    context 'for given board #2' do
      let(:game) { Chess.new }
      subject(:get_enemies_test) { described_class.new(game) }

      before do
        game.set_board_state('rnbqkbnr/pppp1ppp/8/8/2B1Pp2/8/PPPP2PP/RNBQK1NR b KQkq - 1 3')
      end

      it 'returns the expected data structure' do
        expected = get_enemies_test.get_enemies(game.board.bking)
        expect(expected).to include(Array).exactly(2).times
        expect(expected[0]).to_not include(Cell)
        expect(expected[1]).to include(Cell).exactly(15).times
      end
    end

    context 'for given board #3' do
      let(:game) { Chess.new }
      subject(:get_enemies_test) { described_class.new(game) }

      before do
        game.set_board_state('rnbqkbnr/pppp2pp/8/5p1B/2B1P3/3P4/PPP3PP/RN1QK1NR b KQkq - 1 3')
      end

      it 'returns the expected data structure' do
        expected = get_enemies_test.get_enemies(game.board.bking)
        expect(expected).to include(Array).exactly(2).times
        expect(expected[0]).to include(Cell).exactly(1).times
        expect(expected[1]).to include(Cell).exactly(14).times
      end
    end

    context 'for given board #4' do
      let(:game) { Chess.new }
      subject(:get_enemies_test) { described_class.new(game) }

      before do
        game.set_board_state('rn1qk1nr/ppp3pp/3pb3/5p2/4P2b/3PB3/PPP3PP/RN1QK1NR w KQkq - 1 3')
      end

      it 'returns the expected data structure' do
        expected = get_enemies_test.get_enemies(game.board.wking)
        expect(expected).to include(Array).exactly(2).times
        expect(expected[0]).to include(Cell).exactly(1).times
        expect(expected[1]).to include(Cell).exactly(14).times
      end
    end

    context 'for given board #5' do
      let(:game) { Chess.new }
      subject(:get_enemies_test) { described_class.new(game) }

      before do
        game.set_board_state('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w - - 0 1')
      end

      it 'returns the expected data structure' do
        expected = get_enemies_test.get_enemies(game.board.wking)
        expect(expected).to include(Array).exactly(2).times
        expect(expected[0]).to include(Cell).exactly(0).times
        expect(expected[1]).to include(Cell).exactly(16).times
      end
    end
  end

  context '#dangers' do
    context 'for given board #1' do
      let(:game) { Chess.new }
      subject(:danger_test) { described_class.new(game) }

      before do
        game.set_board_state('8/8/8/8/2pkP3/2N5/8/7K b - - 1 2')
      end

      it 'returns the expected data structure' do
        expected = danger_test.dangers(game.board.bking)
        expect(expected).to be_a(Array)
        expect(expected).to include(Cell).exactly(12).times
      end
    end
  end

  context '#attacks' do
    context 'for given board #1' do
      let(:game) { Chess.new }
      subject(:attacks_test) { described_class.new(game) }

      before do
        game.set_board_state('8/8/8/8/2pkP3/2N5/8/7K b - - 1 2')
      end

      it 'returns the expected data structure' do
        expected = attacks_test.attacks(game.board.bking)
        expect(expected).to be_a(Array)
        expect(expected).to include(Cell).exactly(11).times
      end
    end
  end

  context '#legal_moves' do
    let(:game) { Chess.new }
    subject(:legal_moves_test) { described_class.new(game) }

    context 'when provided a Knight' do
      context 'with other pieces on the board' do
        it 'correctly shows moves' do
          game.set_board_state('8/8/8/4k3/4r3/8/4N3/K7 w - - 0 1')
          cell = game.cell('e2')
          eligible = %w[c1 c3 d4 f4 g3 g1].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a Queen' do
      context 'on an empty board' do
        it 'starting at d4, returns the correct list of available moves' do
          game.set_board_state('k7/8/8/8/3q4/8/8/7K b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[d8 d7 d6 d5 d3 d2 d1 a4 b4 c4 e4 f4 g4 h4 e5 f6 g7 h8 c3 b2 a1 c5 b6 a7 e3 f2 g1].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end

      context 'on a board with mixed pieces in its path' do
        it 'starting at d4, returns the correct list of available moves including eligible captures' do
          game.set_board_state('k7/3p4/8/8/3qn3/8/3P1P2/7K b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[d6 d5 d3 d2 a4 b4 c4 e5 f6 g7 h8 c3 b2 a1 c5 b6 a7 e3 f2].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a King' do
      context 'when there is a friendly on one side, and an enemy on the other' do
        it 'starting at d4, returns the correct list of available moves including one capture' do
          game.set_board_state('8/8/8/8/2pkP3/2N5/8/7K b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[c5 c3 d3 e3 e5].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end

      context 'when there are a limited set of moves, but no check' do
        it 'correctly shows moves that prevent self-checking' do
          game.set_board_state('8/8/8/2k5/3R4/2B5/8/4K3 b - - 1 2')
          cell = game.cell('c5')
          eligible = %w[b6 c6 b5].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end

        it 'correctly shows moves that prevent self-checking' do
          game.set_board_state('8/8/8/8/2pkP3/3B4/8/8 b - - 1 2')
          cell = game.cell('d4')
          eligible = %w[c3 d3 e3 c5 e5].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end

        it 'correctly shows one move that prevents self-check' do
          game.set_board_state('7k/8/2r5/8/3b4/8/8/1K6 w - - 0 1')
          cell = game.cell('b1')
          eligible = %w[a2]
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end

        it 'correctly shows two moves available to the king (position 2 of Perft boards)' do
          game.set_board_state('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w - - 0 1')
          cell = game.cell('e1')
          eligible = %w[d1 f1]
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end

      context 'when there are a limited set of moves, and we are in single check' do
        it 'correctly shows moves that would get out of a check' do
          game.set_board_state('k1q5/8/3r4/8/8/8/3K4/8 w - - 0 1')
          cell = game.cell('d2')
          eligible = %w[e1 e2 e3].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end

      context 'when there are a limited set of moves, and we are in double check' do
        it 'correctly shows moves that would get out of a check' do
          game.set_board_state('k7/8/3r4/8/8/8/q2K4/8 w - - 0 1')
          cell = game.cell('d2')
          eligible = %w[c1 c3 e1 e3].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a Knight piece preventing a check' do
      context 'with other pieces on the board in a position to check' do
        it 'correctly shows 0 moves as any move would result in a self-check' do
          game.set_board_state('8/8/8/4k3/4n3/8/4R3/K7 b - - 0 1')
          cell = game.cell('e4')
          eligible = %w[]
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a Rook piece preventing a check' do
      context 'with other pieces on the board in a position to check' do
        it 'correctly shows only 2 moves as any other moves would result in a self-check' do
          game.set_board_state('8/8/8/4k3/4r3/8/4R3/K7 b - - 0 1')
          cell = game.cell('e4')
          eligible = %w[e3 e2].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end

        it 'correctly shows only 3 moves as any other moves would result in a self-check' do
          game.set_board_state('8/8/4k3/4r3/8/8/4R3/K7 b - - 0 1')
          cell = game.cell('e5')
          eligible = %w[e4 e3 e2].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a Queen piece preventing a check' do
      context 'with other pieces on the board in a position to check' do
        it 'correctly shows 0 moves as black should move the king to prevent a check-mate' do
          game.set_board_state('8/1k6/2q5/2N5/8/8/4R1B1/K7 b - - 0 1')
          cell = game.cell('c6')
          eligible = %w[]
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end

        it 'correctly shows only 2 moves as any other moves would result in a self-check' do
          game.set_board_state('8/8/8/3k4/4q3/8/6Q1/K7 b - - 0 1')
          cell = game.cell('e4')
          eligible = %w[f3 g2].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end

        it 'correctly shows only 4 moves as any other moves would result in a self-check' do
          game.set_board_state('8/1k6/2q5/8/8/8/4R1B1/K7 b - - 0 1')
          cell = game.cell('c6')
          eligible = %w[d5 e4 f3 g2].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end

        it 'correctly shows all moves as another friendly piece can prevent a self-check' do
          game.set_board_state('8/1k6/2p5/3q4/8/8/4R1B1/K7 b - - 0 1')
          cell = game.cell('d5')
          eligible = %w[d8 d7 d6 d4 d3 d2 d1 e6 f7 g8 e5 f5 g5 h5 e4 f3 g2 c4 b3 a2 a5 b5 c5].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end

        it 'correctly shows all moves as another friendly piece can prevent a self-check' do
          game.set_board_state('8/1k6/2p5/8/8/5q2/4R1B1/K7 b - - 0 1')
          cell = game.cell('f3')
          eligible = %w[f1 f2 f4 f5 f6 f7 f8 a3 b3 c3 d3 e3 g3 h3 e2 g2 e4 d5 g4 h5].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end

        it 'correctly shows all moves as another friendly piece can prevent a self-check' do
          game.set_board_state('8/1k6/8/3p4/8/5q2/4R1B1/K7 b - - 0 1')
          cell = game.cell('f3')
          eligible = %w[f1 f2 f4 f5 f6 f7 f8 a3 b3 c3 d3 e3 g3 h3 e2 g2 e4 g4 h5].sort
          expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
        end
      end
    end

    context 'when provided a white King at d1 in a check situation' do
      before do
        game.set_board_state('k2b4/2p2n2/1p6/8/7R/4n3/7P/3K2B1 w - - 0 1')
      end

      it 'when selecting the friendly Bishop, corretly shows only one capture move' do
        cell = game.cell('g1')
        eligible = %w[e3]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'when selecting the King, correctly shows four moves to resovle check' do
        cell = game.cell('d1')
        eligible = %w[c1 e1 d2 e2].sort
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a black King at g1 in a check situation' do
      before do
        game.set_board_state('2Q3k1/6pp/5r1q/6N1/1P5P/6P1/5P2/6K1 b - - 0 1')
      end

      it 'when selecting the friendly Rook, correctly shows only one blocking move to prevent a check' do
        cell = game.cell('f6')
        eligible = %w[f8]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'when selecting the King, correctly shows no available moves' do
        cell = game.cell('g8')
        eligible = %w[]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'when selecting a friendly pawn, correctly shows no available moves' do
        cell = game.cell('g7')
        eligible = %w[]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'when selecting a friendly queen, correctly shows no available moves' do
        cell = game.cell('h6')
        eligible = %w[]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a black King in check by a white knight on d6' do
      before do
        game.set_board_state('1nbqkbnr/rppp1pp1/p2N4/4p2p/4P2P/8/PPPP1PP1/R1BQKBNR b KQk - 1 5')
      end

      it 'when selecting the King, correctly shows only one move' do
        cell = game.cell('e8')
        eligible = %w[e7]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'when selecting the pawn, correctly shows only one move' do
        cell = game.cell('c7')
        eligible = %w[d6]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'when selecting the Bishop, correctly shows only one move' do
        cell = game.cell('f8')
        eligible = %w[d6]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a white King in checkmate at e1, there should be no legal moves' do
      it 'when selecting the pawn at e2, correctly shows no moves' do
        game.set_board_state('r1b1k2r/ppppqppp/2n5/8/1PP2B2/3n1N2/1P1NPPPP/R2QKB1R w KQkq - 1 9')
        cell = game.cell('e2')
        expect(legal_moves_test.legal_moves(cell)).to eq([])
      end

      it 'when selecting the pawn at e3, correctly shows no legal moves' do
        game.set_board_state('r1b1k2r/ppppqppp/2n5/8/1PP2B2/3nPN2/1P1N1PPP/R2QKB1R w KQkq - 1 9')
        cell = game.cell('e3')
        expect(legal_moves_test.legal_moves(cell)).to eq([])
      end
    end

    context 'when provided a white pawn with an available passant capture during a check' do
      it 'correctly shows an available en passant to resolve the check' do
        game.set_board_state('r3k2r/pp1n1ppp/8/2pP1b2/2PK1PqP/1Q2P3/P5P1/2B2B1R w - c6 0 2')
        cell = game.cell('d5')
        eligible = %w[c6]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'correctly shows an available move for the king in check' do
        game.set_board_state('r3k2r/pp1n1ppp/8/2pP1b2/2PK1PqP/1Q2P3/P5P1/2B2B1R w - c6 0 2')
        cell = game.cell('d4')
        eligible = %w[c3]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a white pawn with an available passant capture during a check' do
      it 'shows the right moves' do
        game.set_board_state('r3k2r/pp1n1ppp/8/2pP1b2/2PK1PqP/1Q2P3/P5P1/2B2B1R w - c6 0 2')
        cell = game.cell('d5')
        eligible = %w[c6]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a white pawn with no special moves available' do
      it 'shows the right moves for pawn at a2' do
        game.set_board_state('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w - - 0 1')
        cell = game.cell('a2')
        eligible = %w[a3 a4]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'shows the right moves for pawn at b2' do
        game.set_board_state('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w - - 0 1')
        cell = game.cell('b2')
        eligible = %w[b3]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'shows the right moves for pawn at c2' do
        game.set_board_state('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w - - 0 1')
        cell = game.cell('c2')
        eligible = %w[]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'shows the right moves for pawn at g2' do
        game.set_board_state('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w - - 0 1')
        cell = game.cell('g2')
        eligible = %w[g3 g4 h3].sort
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a white pawn with a passant capture available' do
      it 'shows the right moves for pawn at f5' do
        game.set_board_state('k7/8/8/5Pp1/8/8/8/K7 w - g6 0 2')
        cell = game.cell('f5')
        eligible = %w[f6 g6]
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end
    end

    context 'when provided a board with pawns locked' do
      it 'shows the right moves for black pawn at c4' do
        game.set_board_state('k1qn4/8/8/4p3/2p1P3/2P5/8/4QN1K b - - 0 1')
        cell = game.cell('c4')
        eligible = []
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end

      it 'shows the right moves for white pawn at e4' do
        game.set_board_state('k1qn4/8/8/4p3/2p1P3/2P5/8/4QN1K b - - 0 1')
        cell = game.cell('e4')
        eligible = []
        expect(legal_moves_test.legal_moves(cell)).to eq(eligible)
      end
    end
  end

  context 'testing with Perft boards from https://www.chessprogramming.org/Perft_Results' do
    let(:game) { Chess.new }
    subject(:legal_moves_test) { described_class.new(game) }

    it 'given position 2 should return the right amount of moves' do
      # This test is identical to the source except there are no castle rights,  mostly because I haven't tackled castling yet.
      game.set_board_state('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w - - 0 1')
      moves = 0
      game.board.data.each do |rank|
        rank.each do |cell|
          next if cell.empty? || cell.piece.black?

          legal = legal_moves_test.legal_moves(cell)
          # puts "moves from #{cell.to_fen}#{cell}: #{legal}"
          moves += legal.length
        end
      end
      expect(moves).to eq(46)
    end

    it 'given position 3 should return the right amount of moves' do
      game.set_board_state('8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1')
      moves = 0
      game.board.data.each do |rank|
        rank.each do |cell|
          next if cell.empty? || cell.piece.black?

          legal = legal_moves_test.legal_moves(cell)
          # puts "moves from #{cell.to_fen}#{cell}: #{legal}"
          moves += legal.length
        end
      end

      expect(moves).to eq(14)
    end

    it 'given position 4, should return the right amount of total moves' do
      game.set_board_state('r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1')
      moves = 0
      game.board.data.each do |rank|
        rank.each do |cell|
          next if cell.empty? || cell.piece.white?

          legal = legal_moves_test.legal_moves(cell)
          # puts "moves from #{cell.to_fen}#{cell}: #{legal}"
          moves += legal.length
        end
      end

      expect(moves).to eq(6)
    end

    it 'given position 5 without castle rights should return the right amount of total moves' do
      game.set_board_state('rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w - - 1 8')
      moves = 0
      game.board.data.each do |rank|
        rank.each do |cell|
          next if cell.empty? || cell.piece.black?

          legal = legal_moves_test.legal_moves(cell)
          # puts "moves from #{cell.to_fen}#{cell}: #{legal}"
          moves += legal.length
        end
      end

      expect(moves).to eq(40)
    end

    it 'given position 6 should return the right amount of total moves' do
      game.set_board_state('r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10')
      moves = 0
      game.board.data.each do |rank|
        rank.each do |cell|
          next if cell.empty? || cell.piece.black?

          legal = legal_moves_test.legal_moves(cell)
          # puts "moves from #{cell.to_fen}#{cell}: #{legal}"
          moves += legal.length
        end
      end

      expect(moves).to eq(46)
    end

    xcontext 'boards with castling rights' do
      it 'given position 2 should return the right amount of moves' do
        game.set_board_state('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1')
        moves = 0
        game.board.data.each do |rank|
          rank.each do |cell|
            next if cell.empty? || cell.piece.black?

            legal = legal_moves_test.legal_moves(cell)
            # puts "moves from #{cell.to_fen}#{cell}: #{legal}"
            moves += legal.length
          end
        end
        expect(moves).to eq(48)
      end

      it 'given position 5 should return the right amount of total moves' do
        game.set_board_state('rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8')
        moves = 0
        game.board.data.each do |rank|
          rank.each do |cell|
            next if cell.empty? || cell.piece.black?

            legal = legal_moves_test.legal_moves(cell)
            # puts "moves from #{cell.to_fen}#{cell}: #{legal}"
            moves += legal.length
          end
        end

        expect(moves).to eq(44)
      end
    end
  end
end
