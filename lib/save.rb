# frozen_string_literal: true

# lib/save.rb

class Save
  def initialize; end

  def self.save_to_file(filename, fen)
    File.open(filename, 'w') { |f| f.write(fen) }
  end

  def self.load_from_file(filename)
    return nil unless File.exist?(filename)

    File.read(filename)
  end
end