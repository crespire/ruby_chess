# frozen_string_literal: true

# lib/castle.rb

require_relative 'chess'
require_relative 'board'
require_relative 'cell'
require_relative 'piece'
require_relative 'movement'
require_relative 'pieces/all_pieces'


class Castle
  def initialize(game)
    @game = game
    @board = game.board
  end
end