require_relative "game"
require_relative "input"
require "yaml"


module ChessEngine
  class NoGamesError < StandardError; end

  ##
  # A Simple command line interface for the Chess Game

  class CLI
    include Input

    ##
    # Starts a new game session

    def initialize
      begin
        mode = get_input("\nChoose the game mode:\n1. New game\n2. Continue\nEnter your choice (1 or 2): ", /^[12]$/)
        @game = mode == "1" ? Game.new : choose_game
      rescue NoGamesError => e
        puts "#{e.message}. Try again"
        retry
      end
      play
      save if save?
    end

    private

    def play
      until @game.over?
        puts "\n#{@game.name}\n#{@game.draw}"
        declare_check if @game.check?
        begin
          promotion if @game.needs_promotion?
          print "#{@game.current_color.to_s.capitalize}'s move (e. g. \"e2e4\" or \"exit\" or \"000\"/\"00\" (for castling)): "
          move = gets.chomp.gsub(/\s+/, " ")
          case move
          when /^[oOоО0]{2}$/ #matches cyrillic letters
            @game.castling(:short)
          when /^[oOоО0]{3}$/
            @game.castling(:long)
          when /^[a-h][1-8][a-h][1-8]$/i
            @game.move(move)
          when /^exit$/i
            return
          else
            raise InvalidMove, "Incorrect input"
          end
        rescue InvalidMove => e
          puts "#{e.message}. Try again"
          retry
        end
      end
      game_over
    end

    def promotion
      pieces = ["Queen", "Rook", "Knight", "Elephant"]
      choice = get_input(
        "Pawn promotion. Choose the new piece:\n1. Queen\n2. Rook\n3. Knight\n4. Elephant",
        /^[1-4]$/, "Input must be a single digit"
      )
      @game.promotion(pieces[choice - 1])
    end

    def declare_check
      puts "#{@game.current_color.to_s.capitalize} player is given a check"
    end

    def declare_checkmate
      puts "#{@game.current_color.to_s.capitalize} player got mated!"
    end

    def game_over
      puts @game.draw
      if @game.check?
        declare_checkmate
      else
        puts "Stalemate!"
      end
    end

    def choose_game
      saved_names = Dir[File.join(CLI.dirname, "/*.yaml")].map { |filename| File.basename(filename, ".yaml") }
      raise NoGamesError, "You have no saved games" if saved_names.empty?
      puts "\nSaved games (#{saved_names.size}):"
      saved_names.each { |name| puts name }
      filename = get_input("Enter the name of the game that you want to continue: ",
        nil, "Such game doesn't exist, try again") { |input| saved_names.include?(input) }
      return YAML::load(File.read(File.join(CLI.dirname, "#{filename}.yaml")))
    end

    def save?
      choice = get_input("Do you want to save the game? (y/n): ", /^[yn]$/i)
      choice == "y" ? true : false
    end

    def save
      @game.name ||= get_input("Enter the game name: ", /[^\/\>\<\|\:\&]+/)
      game = YAML::dump(@game)
      Dir.mkdir(CLI.dirname) unless File.exists?(CLI.dirname)
      File.open(File.join(CLI.dirname, "#{@game.name}.yaml"), "w") { |file| file.write(game) }
    end

    def CLI.dirname
      File.join(Dir.home, "./.chess_engine")
    end
  end
end
