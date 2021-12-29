# frozen_string_literal: true

# spec/board_spec.rb

require_relative '../lib/board.rb'

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
  end
end