require_relative 'mastermind'
require_relative 'mastermind_ai'

include Mastermind_ai

game = Mastermind.new

game.begin_game