module Game
	class Mastermind

		def initialize
			@code = generate_code
			@guess = []
		end

		def generate_code
			code = []
			4.times do |x|
				code << rand(1..6)			
			end
			code
			#[1,1,1,4]
		end

		def begin_game
			introduction
			new_game
		end

		def new_game
			reset_variables
			choose_role
			enter_code if @player_role == "make"
			guessing_loop
		end

		def guessing_loop
			while game_continues?
				puts @remaining_turns == 1 ? "\n#{@remaining_turns} guess remaining." : "\n#{@remaining_turns} guesses remaining."
				@player_role == "guess" ? player_turn : ai_turn
				@remaining_turns -= 1
			end
			correct_guess? ? guesser_wins : guesser_loses
			new_game if play_again?
		end

		def choose_role
			puts "Would you like to be the one making or guessing the code?"
			puts "[1] - Guess the code\n[2] - Make the code"
			player_role = gets.chomp.upcase[0]
			until player_role == "1" || player_role == "2"
				puts "Sorry, please enter either 1 or 2.\n[1] - Guess the code\n[2] - Make the code"
				player_role = gets.chomp.upcase[0]
			end
			player_role == "1" ? @player_role = "guess" : @player_role = "make"
		end

		def reset_variables
			@correct_guess = false
			@guess = []
			@code = generate_code
			@remaining_turns = 12
			@feedback_log = []
			# -- AI variables --
			@ai_num = 1
			@ai_stage_one = true
			@ai_stage_two = false
			@original_feedback = false
		end

		def introduction
			puts "--------Welcome to Mastermind--------\n "
			puts "The code consists of 4 digits, each between 1 and 6."
			puts "You have 12 attempts to guess the correct code."
			puts "After each guess you'll be given feedback: x/y"
			puts "x: The number of correct digits in the correct position."
			puts "y: The number of digits in the wrong position.\n "
		end

# ------- Player Guessing --------------

		def player_turn
			#@remaining_turns -= 1
			puts "Enter your guess:"
			@guess = gets.chomp.chars.map! {|x| x.to_i}
			puts ""
			until valid_entry?
				enter_valid_entry
			end
			unless correct_guess?
				calculate_feedback
				update_logs
				display_feedback
			end
		end

# -------- Entry validation ----------------

		def valid_entry?
			@player_role == "guess" ? entry = @guess : entry = @code
			if entry.count != 4 || !(entry.all? { |x| (1..6).include? x.to_i } )
				false
			else
				true
			end
		end

		def enter_valid_entry
			@player_role == "guess" ? word = "guess" : word = "code"
			puts "Please enter a valid #{word}. (4 digits between 1 and 6)."
			entry = gets.chomp.chars.map! {|x| x.to_i}
			@player_role == "guess" ? @guess = entry : @code = entry
		end

# --------------------------------------------		

		def game_continues?
			(@remaining_turns > 0) && !(correct_guess?) ? true : false
		end

		def correct_guess?
			@guess == @code ? true : false
		end

		def calculate_feedback
			code_copy, guess_copy = @code.dup, @guess.dup
			correct_position, wrong_position = 0, 0
			guess_copy.each_with_index do |x, i|
				if code_copy[i] == x
					correct_position += 1
					code_copy[i], guess_copy[i] = nil, nil
				end
			end
			guess_copy.each_with_index do |x, i|
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
			print @player_role == "guess" ? "Congratulations! You " : "The computer "
			print "guessed the correct code (#{@code.join("")}) after #{12-@remaining_turns} guesses!\n"
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

		# ------------- Computer Guessing -------------

		def enter_code
			puts "Enter a code for the computer to guess. (4 digits between 1 and 6)."
			@code = gets.chomp.chars.map! {|x| x.to_i}
			until valid_entry?
				enter_valid_entry
			end
		end

		def ai_turn
			sleep(0.05)
			p "---------" # Test line
			if @ai_stage_one == true
				@guess = [1, 1, @ai_num, @ai_num]
				@ai_num += 1 if @ai_num < 6
				p @guess
				unless correct_guess?
					@original_feedback ||= @feedback
					#if @remaining_turns
					# if @original_feedback && @feedback != @original_feedback
						# Do something to assign numbers to left/right variables
					# end
					calculate_feedback
					update_logs
					display_feedback
				end
			end
		end

		def ai_find_included_numbers

		end


	end # End of Mastermind class
end # End of Game module