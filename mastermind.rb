module Game
	class Mastermind

		def initialize
			@code = generate_code
			@guess = []
		end

		def reset_variables
			@correct_guess = false
			@guess = []
			@code = generate_code
			@remaining_turns = 12
			@feedback_log = []
			# -- AI variables --
			@ai_num = 1
			@ai_stage = 1
			@original_feedback = false
			@left_column = []
			@right_column = []
			@stage_three_iteration = 1
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

		def generate_code
			code = []
			4.times do |x|
				code << rand(1..6)
			end
			code
			[1,1,1,1]
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
			puts "Enter your guess:"
			@guess = gets.chomp.chars.map! {|x| x.to_i}
			puts ""
			until valid_entry?
				enter_valid_entry
			end
			submit_guess
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

		def submit_guess
			unless correct_guess?
				calculate_feedback
				update_logs
				display_feedback
			end
		end

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
			@feedback_total = @feedback[:correct_position] + @feedback[:wrong_position]
		end

		# Add the most recent feedback to the log.
		def update_logs
			@feedback_log << [@guess.join(""), @feedback[:correct_position], @feedback[:wrong_position]]
		end

		def display_feedback
			@feedback_log.each_with_index do |x, i|
				puts "Turn #{i+1}: #{x[0]} #{x[1]}/#{x[2]}"
			end
		end

		def guesser_wins
			print @player_role == "guess" ? "Congratulations! You " : "The computer "
			print "guessed the correct code (#{@code.join("")}) after #{12-@remaining_turns} "
			print @remaining_turns == 11 ? "guess.\n" : "guesses.\n"
			# guesses!\n"
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

		# The user enters a code for the AI to guess.
		def enter_code
			puts "Enter a code for the computer to guess. (4 digits between 1 and 6)."
			@code = gets.chomp.chars.map! {|x| x.to_i}
			until valid_entry?
				enter_valid_entry
			end
		end

		# The main cycle repeating for the AI's turns.
		def ai_turn
			sleep(0.05)
			if @remaining_turns == 12
				# Actions for first turn.
				@guess = [1, 1, @ai_num, @ai_num]
				submit_guess
				@original_feedback = @feedback
				@original_feedback_total = @feedback_total
				@ai_num += 1
				if @feedback_total == 0
					@ai_stage = 2
					@block_number = 1
				end
			elsif @ai_stage == 1
				ai_stage_one
			elsif @ai_stage == 2
				ai_stage_two
			elsif @ai_stage == 3
				ai_stage_three
			end
		end

		# Identify a number not included in the code.
		def ai_stage_one
			@guess = [1, 1, @ai_num, @ai_num]
			submit_guess
			@ai_num += 1
			if @feedback_total <= @original_feedback_total && @remaining_turns < 12
				@block_number = @ai_num - 1
				@ai_stage = 2
				stage_two_initial_check
			end
		end

		# Fill the left and right columns.
		def ai_stage_two
			@guess = [@block_number, @block_number, @ai_num, @ai_num]
			submit_guess
			@ai_num += 1
			if @feedback_total > 0
				@feedback[:correct_position].times { @right_column << @guess[2] }
				@feedback[:wrong_position].times { @left_column << @guess[2] }
			end
			if @left_column.count == 2 && @right_column.count == 2
				@ai_stage = 3
			elsif @ai_num == 7				
				fill_empty_columns
				@ai_stage = 3
			elsif @ai_num == 6 && (@left_column + @right_column).detect{ |num| (@left_column + @right_column).count(num) > 1 } == nil
				fill_sixes
				@ai_stage = 3
			end
		end

		# Guess the corret code.
		def ai_stage_three
			@stage_3_order_1 = [@left_column[0], @left_column[1], @right_column[0], @right_column[1]]
			@stage_3_order_2 = [@left_column[0], @left_column[1], @right_column[1], @right_column[0]]
			@stage_3_order_3 = [@left_column[1], @left_column[0], @right_column[0], @right_column[1]]
			@stage_3_order_4 = [@left_column[1], @left_column[0], @right_column[1], @right_column[0]]
			case @stage_three_iteration
			when 1
				@guess = @stage_3_order_1
			when 2
				@guess = @stage_3_order_2
			when 3
				@guess = @stage_3_order_3
			when 4
				@guess = @stage_3_order_4
			end
			submit_guess
			@stage_three_iteration += 1
		end

		# Reviews the feedback log to add numbers to the left/right columns when stage 2 is first triggered.
		def stage_two_initial_check
			# Most recent turn
			@feedback_log[-1][1].to_i.times do
				@left_column << 1
			end
			@feedback_log[-1][2].to_i.times do
				@right_column << 1
			end
			x = -2
			until x == 0 - @feedback_log.count
				# Establishing which instance of feedback we're looking at.
				current_feedback = []
				current_feedback << (@feedback_log[x][1].to_i - @feedback_log[-1][1].to_i) # Amount correct
				current_feedback << (@feedback_log[x][2].to_i - @feedback_log[-1][2].to_i) # Amount wrong
				current_feedback << @feedback_log[x][0] # Guess

				# Adding numbers to columns based on feedback.
				current_feedback[0].to_i.times { @right_column << current_feedback[2][2].to_i }
				current_feedback[1].to_i.times { @left_column << current_feedback[2][2].to_i }

				x -= 1
			end
			@ai_stage = 3 if @left_column.count == 2 && @right_column.count == 2
		end

		# Used for deailing with a number appearing in the code more than twice.
		def fill_empty_columns
			both_columns = @left_column + @right_column
			missing_number = both_columns.detect{ |num| both_columns.count(num) > 1 }
			while @left_column.count < 2 || @right_column.count < 2
				@left_column << missing_number if @left_column.count < 2
				@right_column << missing_number if @right_column.count < 2
			end
		end

		# Adds 6 to any remaining empty spaces in the left/right columns.
		def fill_sixes
			both_columns = @left_column + @right_column
			while @left_column.count < 2 || @right_column.count < 2
				@left_column << 6 if @left_column.count < 2
				@right_column << 6 if @right_column.count < 2
			end
		end

	end # End of Mastermind class
end # End of Game module