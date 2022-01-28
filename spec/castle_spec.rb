# frozen_string_literal: true

# spec/castle_spec.rb

require_relative '../lib/board'
require_relative '../lib/chess'
require_relative '../lib/castle'

describe Castle do
  it 'when given a black King being moved, it updates castle rights on game.' do
    game = Chess.new
    game.set_board_state('2k5/8/8/8/8/8/8/R3K2R w KQ - 0 1')
    manager = described_class.new(game)
    cell = game.cell('e1')
    expect(game.castle).to eq('KQ')
    manager.update_rights(game, cell.piece, cell)
    expect(game.castle).to eq('-')
  end
end