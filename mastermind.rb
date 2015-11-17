module Game
	class Mastermind

		def initialize
			@code = generate_code
		end

		def generate_code
			code = []
			4.times do |x|
				code << rand(1..6)			
			end
			code
		end

		def begin_game
			introduction
			new_game
		end

		def new_game
			reset_variables
			while game_continues?
				turn
			end
			correct_guess? ? guesser_wins : guesser_loses
			new_game if play_again? 
		end

		def reset_variables
			@correct_guess = false
			@code = generate_code
			@remaining_turns = 12
			@feedback_log = []
		end

		def introduction
			puts "--------Welcome to Mastermind--------\n "
			puts "The code consists of 4 digits, each between 1 and 6."
			puts "You have 12 attempts to guess the correct code."
			puts "After each guess you'll be given feedback: x/y"
			puts "x: The number of correct digits in the correct position."
			puts "y: The number of digits in the wrong position.\n "
		end

		def turn
			puts @remaining_turns == 1 ? "\n#{@remaining_turns} guess remaining." : "\n#{@remaining_turns} guesses remaining."
			@remaining_turns -= 1
			puts "Enter your guess:"
			@guess = gets.chomp.chars.map! {|x| x.to_i}
			puts ""
			until valid_guess?
				enter_valid_guess
			end
			unless correct_guess?
				calculate_feedback
				update_logs
				display_feedback
			end
		end

		def valid_guess?
			if (@guess.count != 4) || !(@guess.all? { |x| (1..6).include? x.to_i })
				false
			else
				true
			end
		end

		def enter_valid_guess
			puts "Please enter a valid guess. (4 digits between 1 and 6)"
			@guess = gets.chomp.split("")
		end

		def game_continues?
			(@remaining_turns > 0) && !(correct_guess?) ? true : false
		end

		def correct_guess?
			@guess == @code ? true : false
		end

		def calculate_feedback
			code_copy = @code.dup
			correct_position = 0
			wrong_position = 0
			@guess.each_with_index do |x, i|
				if code_copy[i] == x
					correct_position += 1
					code_copy[i] = nil
					x = nil
				end
			end
			@guess.each_with_index do |x, i|
				if x != nil
					if code_copy.include?(x)
					wrong_position += 1
					code_copy[code_copy.index(x)] = nil
				end
			end	
			end
			@feedback = { :correct_position => correct_position,
										:wrong_position => wrong_position }
		end

		def update_logs
			@feedback_log << [@guess.join(""), "#{@feedback[:correct_position]}/#{@feedback[:wrong_position]}"]
		end

		def display_feedback
			@feedback_log.each_with_index do |x, i|
				puts "Turn #{i+1}: #{x[0]} #{x[1]}"
			end
		end

		def guesser_wins
			puts "Congratulations! You guessed the correct code (#{@code.join("")}) after #{12-@remaining_turns} guesses!"
		end

		def guesser_loses
			puts "\nOut of turns! The correct code was #{@code.join("")}."
		end

		def play_again?
			puts "Would you like to play again? [Y/N]"
			answer = gets.chomp[0].upcase
			while answer != "Y" && answer != "N"
				puts "Please enter either Y or N."
				answer = gets.chomp[0].upcase
			end
			answer == "Y" ? true : false
		end

	end # End of Mastermind class
end # End of Game module