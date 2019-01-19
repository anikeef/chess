require "./lib/chesspiece.rb"

class King < ChessPiece
  MOVES = [[0, 1], [0, -1], [1, 0], [-1, 0],
          [1, 1], [1, -1], [-1, 1], [-1, -1]]

  def initialize(color, board, position)
    super
    @symbol = (@color == :black) ? "\u265A" : "\u2654"
  end

  def valid_moves(moves = MOVES)
    super(moves).reject { |move| fatal_move?(move) }
  end

  def attacked?
    direction = @color == :white ? 1 : -1
    attacks_king?(Pawn, [[1, direction], [-1, direction]]) ||
    attacks_king?(Knight, Knight::MOVES) ||
    attacks_king?(King, King::MOVES) ||
    attacks_king_recursive?(Elephant, Queen) ||
    attacks_king_recursive?(Rook, Queen)
  end

  def attacks_king?(piece_class, moves)
    moves.any? do |move|
      coordinates = relative_coordinates(move)
      piece = @board.exists_at?(coordinates) ? @board.at(coordinates) : nil
      !piece.nil? && piece.color != @color && piece.class == piece_class
    end
  end

  def attacks_king_recursive?(*classes)
    classes[0]::MOVES.any? do |move|
      line = repeated_move(move)
      piece = line.empty? ? nil : @board.at(line.last)
      !piece.nil? && piece.color != @color && classes.include?(piece.class)
    end
  end
end
