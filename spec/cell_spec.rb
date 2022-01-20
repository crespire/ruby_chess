# frozen_string_literal: true

# spec/cell_spec.rb

require_relative '../lib/cell'

describe Cell do
  context 'on empty initialize' do
    subject(:cell) { described_class.new }

    it 'defaults to empty' do
      expect(cell.empty?).to be_truthy
    end

    it 'has no name' do
      expect(cell.name).to be_nil
    end

    it 'returns the correct answer for filled?' do
      expect(cell.full?).to be false
    end

    it 'returns nil on hostility check' do
      expect(cell.hostile?('N')).to be_nil
      expect(cell.hostile?('n')).to be_nil
      expect(cell.friendly?('N')).to be_nil
      expect(cell.friendly?('n')).to be_nil
    end
  end

  context 'on piece initialize' do
    subject(:cell_knight) { described_class.new('b1', 'N') }

    it 'stores the correct name' do
      expect(cell_knight.name).to eq('b1')
    end

    it 'empty? returns the right status' do
      expect(cell_knight.empty?).to be_falsey
    end

    it 'occupied? return the right status' do
      expect(cell_knight.full?).to be true
    end

    it 'correctly identifies whether another piece is hostile' do
      expect(cell_knight.hostile?('n')).to be_truthy
      expect(cell_knight.hostile?('K')).to be_falsey
    end

    it 'correctly identifies whether another piece is friendly' do
      expect(cell_knight.friendly?('N')).to be true
      expect(cell_knight.friendly?('n')).to be false
    end
  end
end
