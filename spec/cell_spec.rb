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
  end

  context 'on piece initialize' do
    subject(:cell_knight) { described_class.new('b1', 'N') }

    it 'stores the correct information' do
      expect(cell_knight.empty?).to be_falsey
      expect(cell_knight.name).to eq('b1')
    end
  end
end
