# frozen_string_literal: true

# spec/cell_spec.rb

require_relative '../lib/cell'

describe Cell do
  context 'on empty initialize' do
    subject(:cell) { described_class.new }

    it 'defaults to empty' do
      expect(cell.empty?).to be true
    end

    it 'has no name' do
      expect(cell.name).to be_nil
    end

    it 'returns the correct answer for filled?' do
      expect(cell.full?).to be false
    end

    it 'returns nil on hostility check' do
      expect(cell.hostile?(Knight.new('N'))).to be_nil
      expect(cell.hostile?(Knight.new('n'))).to be_nil
      expect(cell.friendly?(Knight.new('N'))).to be_nil
      expect(cell.friendly?(Knight.new('n'))).to be_nil
    end
  end

  context 'on piece initialize' do
    subject(:cell_white_n) { described_class.new('b1', Knight.new('N')) }

    it 'stores the correct name' do
      expect(cell_white_n.name).to eq('b1')
    end

    it 'empty? returns the right status' do
      expect(cell_white_n.empty?).to be false
    end

    it 'occupied? return the right status' do
      expect(cell_white_n.full?).to be true
    end

    it 'correctly identifies whether another piece is hostile' do
      expect(cell_white_n.hostile?(Knight.new('n'))).to be true
      expect(cell_white_n.hostile?(King.new('K'))).to be false
    end

    it 'correctly identifies whether another piece is friendly' do
      expect(cell_white_n.friendly?(King.new('K'))).to be true
      expect(cell_white_n.friendly?(Rook.new('r'))).to be false
    end
  end
end
