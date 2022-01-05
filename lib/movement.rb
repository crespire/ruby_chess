# frozen_string_literal: true

# lib/movement.rb

class Movement
  def initialize(board = nil)
    @board = board
  end

  def valid_moves(cell)
  end

  def find_horizontal_moves(cell)
    col_map = Hash['a', 0, 'b', 1, 'c', 2, 'd', 3, 'e', 4, 'f', 5, 'g', 6, 'h', 7]

    piece = cell.content
    coord = cell.name.chars
    x = col_map[coord[0]]
    y = coord[1]
    offset = piece_offset(piece, 'h')

    east = path(piece, x, y, offset, 'e')
    west = path(piece, x, y, offset, 'w')

    (east + west).uniq.sort
  end

  def find_vertical_moves(cell)
    rank_map = Hash['8', 0, '7', 1, '6', 2, '5', 3, '4', 4, '3', 5, '2', 6, '1', 7]

    piece = cell.content
    coord = cell.name.chars
    x = coord[0]
    y = rank_map[coord[1]]
    offset = piece_offset(piece, 'v')

    north = path(piece, x, y, offset, 'n')
    south = path(piece, x, y, offset, 's')

    (north + south).uniq.sort
  end

  def find_diagonal_moves(cell)
  end

  private

  def piece_offset(piece, direction)
    offsets = {
      'r' => { 'h' => 7,   'v' => 7,   'd' => nil, 'c' => nil },
      'q' => { 'h' => 7,   'v' => 7,   'd' => 7,   'c' => nil },
      'p' => { 'h' => nil, 'v' => 1,   'd' => 1,   'c' => nil },
      'b' => { 'h' => nil, 'v' => nil, 'd' => 7,   'c' => nil },
      'k' => { 'h' => 1,   'v' => 1,   'd' => 1,   'c' => nil },
      'n' => { 'h' => nil, 'v' => nil, 'd' => nil, 'c' => [2, 1] } # c for Knight L
    }

    offsets[piece.downcase][direction]
  end

  def path(piece, x, y, offset, direction)
    result = []
    cols = ('a'..'h').to_a
    ranks = ('1'..'8').to_a.reverse

    case direction
    when 'e', 'w'
      result = path_cardinal(piece, x, y, offset, cols, direction)
    when 'n', 's'
      result = path_cardinal(piece, x, y, offset, ranks, direction)
    end
    result
  end

  def path_cardinal(piece, x, y, offset, change_axis, direction)
    operation = %w[e s].include?(direction) ? proc { |change, i| change + i } : proc { |change, i| change - i }
    keep_rank = %w[e w].include?(direction)
    coords = keep_rank ? proc { |change, keep| "#{change_axis[change]}#{keep}" } : proc { |change, keep| "#{keep}#{change_axis[change]}" }
    change_val = keep_rank ? x : y
    keep_val = keep_rank ? y : x
    result = []
    (1..offset).to_a.each do |i|
      ind = operation.call(change_val, i)
      step = @board.cell(coords.call(ind, keep_val)) if (0..7).include?(ind)
      result << step.to_s if step && (step.empty? || step.capture?(piece))
      break unless step && step.empty? && step.capture?(piece)
    end

    result
  end

  def path_ordinal_main
  end

  def path_ordinal_alt
  end
end
