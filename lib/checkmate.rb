# frozen_string_literal: true

# lib/movement.rb

require_relative 'movement'

class Checkmate
  def initialize(board)
    @board = board
    @movement = Movement.new(@board)
  end
end