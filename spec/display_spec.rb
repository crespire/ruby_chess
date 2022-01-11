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
end