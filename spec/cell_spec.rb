# frozen_string_literal: true

# spec/cell_spec.rb

require_relative '../lib/cell.rb'

describe Cell do
  context 'on initialize' do
    subject(:cell) { described_class.new }

    it 'defaults to empty' do
      expect(cell.empty?).to be_truthy
    end
  end
end