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

    it 'returns nil for capture? as cell is empty' do
      expect(cell.capture?('N')).to be_nil
      expect(cell.capture?('n')).to be_nil
    end

    it 'returns the correct answer for filled?' do
      expect(cell.occupied?).to be false
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
      expect(cell_knight.occupied?).to be true
    end

    it 'correctly identifies whether another peice can attack' do
      expect(cell_knight.capture?('n')).to be_truthy
      expect(cell_knight.capture?('K')).to be_falsey
    end
  end
end
