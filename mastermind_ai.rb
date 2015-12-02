module Mastermind_ai
	
	# The user enters a code for the AI to guess.
	def enter_code
		puts "\nEnter a code for the computer to guess. (4 digits between 1 and 6)."
		puts "Or leave blank for a random code."
		@code = gets.chomp.chars.map! {|x| x.to_i}
		if @code == []
			@code = generate_code
			puts "Ranomly generated code: #{@code.join("")}"
		end
		until valid_entry?
			enter_valid_entry
		end
	end

	# The main cycle repeating for the AI's turns.
	def ai_turn
		puts "Press Enter to run the computer's next guess."
		gets
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
		# Checks if code is almost correct but with the columns backwards.
		if @feedback_log[-1][1] == 0 && @feedback_log[-1][2] == 4
			new_guess = [@guess[1], @guess[0], @guess[3], @guess[2]]
			@guess = new_guess
		else
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
end # End mastermind_ai class