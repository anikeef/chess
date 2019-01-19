class IncorrectInput < StandardError; end

class Player
  attr_reader :color

  COLUMN_LETTERS = ["a", "b", "c", "d", "e", "f", "g", "h"]

  def initialize(color)
    @color = color
  end

  def input_step
    print "#{@color.to_s.capitalize}'s move (e. g. \"e2 e4\"): "
    input = gets.gsub(/\s+/, "")
    raise IncorrectInput, "Input must look like \"e2 e4\" or \"a6b5\"" unless /^[a-h][1-8][a-h][1-8]$/.match?(input)
    [[COLUMN_LETTERS.find_index(input[0]), input[1].to_i - 1],
    [COLUMN_LETTERS.find_index(input[2]), input[3].to_i - 1]]
  end

  def input_promotion
    puts "Pawn promotion. Choose the new piece:\n1. Queen\n2. Rook\n3. Knight\n4. Elephant"
    input = gets.strip
    raise IncorrectInput, "Input must be a single digit" unless /^[1-4]$/.match?(input)
    input.to_i
  end
end
