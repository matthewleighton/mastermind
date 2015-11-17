require_relative '../mastermind.rb'

describe "Mastermind" do

	code = [1, 2, 3, 4]

	before :each do
		@game = Game::Mastermind.new
	end

	describe "#generate_code" do
		it "creates an array" do
			expect(@game.instance_variable_get(:@code)).to be_a Array
		end

		it "is 4 digits long" do
			expect(@game.instance_variable_get(:@code).length).to eq(4) 
		end

		it "is generated randomly each time" do
			first_code = @game.generate_code
			second_code = @game.generate_code
			expect(@game.generate_code).not_to be == (first_code && second_code)
		end
	end

	describe "#valid_guess?" do
		it "returns false if guess is too short" do
			@game.instance_variable_set(:@guess, [1, 2, 3])
			expect(@game.valid_guess?).to eq(false)
		end

		it "returns false if guess is too long" do
			@game.instance_variable_set(:@guess, [1, 2, 3, 4, 5])
			expect(@game.valid_guess?).to eq(false)
		end

		it "returns false if guess contains invalid character" do
			@game.instance_variable_set(:@guess, [1, 2, 3, 7])
			expect(@game.valid_guess?).to eq(false)
		end

		it "returns true for valid guess" do
			@game.instance_variable_set(:@guess, [1, 2, 3, 4])
			expect(@game.valid_guess?).to eq(true)
		end
	end

	describe "#game_continues?" do
		it "returns false when 0 turns remain" do
			@game.instance_variable_set(:@remaining_turns, 0)
			expect(@game.game_continues?).to eq(false)
		end

		it "returns true when 1 turn remains" do
			@game.instance_variable_set(:@remaining_turns, 1)
			expect(@game.game_continues?).to eq(true)
		end

		it "returns false when correct guess is entered" do
			@game.instance_variable_set(:@code, code)
			@game.instance_variable_set(:@guess, code)
			@game.instance_variable_set(:@remaining_turns, 5)
			expect(@game.game_continues?).to eq(false)
		end
	end

	describe "#correct_guess?" do
		it "returns true when guess is same as code" do
			@game.instance_variable_set(:@code, code)
			@game.instance_variable_set(:@guess, code)
			expect(@game.correct_guess?).to eq(true)
		end

		it "returns false when guess is different from code" do
			@game.instance_variable_set(:@code, code)
			@game.instance_variable_set(:@guess, [1, 2, 5, 3])
			expect(@game.correct_guess?).to eq(false)
		end
	end

	describe "#guesser_wins" do
	end

	describe "#calculate_feedback" do
	
		it "returns 0/0 for guess 5555 against code 1234" do
			@game.instance_variable_set(:@code, code)
			@game.instance_variable_set(:@guess, [5, 5, 5, 5])
			feedback = { :correct_position => 0, :wrong_position => 0 }
			expect(@game.calculate_feedback).to eq(feedback)
		end

		it "returns 1/0 for guess 1555 against code 1234" do
			@game.instance_variable_set(:@code, code)
			@game.instance_variable_set(:@guess, [1, 5, 5, 5])
			feedback = { :correct_position => 1, :wrong_position => 0 }
			expect(@game.calculate_feedback).to eq(feedback)
		end

		it "returns 2/2 for guess 3315 against code 1335" do
			@game.instance_variable_set(:@code, [1, 3, 3, 5])
			@game.instance_variable_set(:@guess, [3, 3, 1, 5])
			feedback = { :correct_position => 2, :wrong_position => 2 }
			expect(@game.calculate_feedback).to eq(feedback)
		end

		it "returns 4/0 for guess 1234 against code 1234" do
			@game.instance_variable_set(:@code, code)
			@game.instance_variable_set(:@guess, code)
			feedback = { :correct_position => 4, :wrong_position => 0 }
			expect(@game.calculate_feedback).to eq(feedback)
		end
	end

	describe "#update_logs" do
		it "updates an empty log correctly" do
			@game.instance_variable_set(:@feedback_log, [])
			@game.instance_variable_set(:@guess, [1, 2, 3, 4])
			feedback = { :correct_position => 2, :wrong_position => 1 }
			@game.instance_variable_set(:@feedback, feedback)
			expect(@game.update_logs).to eq([["1234", "2/1"]])
		end

		it "adds to a pre-existing log correctly" do
			old_log = [["1234", "2/1"], ["1251", "1/3"]]
			@game.instance_variable_set(:@feedback_log, old_log)
			@game.instance_variable_set(:@guess, [1, 1, 1, 1])
			feedback = { :correct_position => 3, :wrong_position => 0 }
			@game.instance_variable_set(:@feedback, feedback)
			new_log = [["1234", "2/1"], ["1251", "1/3"], ["1111", "3/0"]]
			expect(@game.update_logs).to eq(new_log)
		end
	end

	describe "#display_feedback" do
		it "outputs the correct feedback" do
			log = [["1234", "2/1"], ["1251", "1/3"], ["1111", "3/0"]]
			@game.instance_variable_set(:@feedback_log, log)
			expect(STDOUT).to receive(:puts).with("Turn 1: 1234 2/1")
			expect(STDOUT).to receive(:puts).with("Turn 2: 1251 1/3")
			expect(STDOUT).to receive(:puts).with("Turn 3: 1111 3/0")
			@game.display_feedback
		end
	end

	describe "#guesser_wins" do
		it "displays the correct information" do
			@game.instance_variable_set(:@code, [1, 2, 3, 4])
			@game.instance_variable_set(:@remaining_turns, 2)
			message = "Congratulations! You guessed the correct code (1234) after 10 guesses!"
			expect(STDOUT).to receive(:puts).with(message)
			@game.guesser_wins
		end
	end

	describe "#guesser_loses" do
		it "displays the correct information" do
			@game.instance_variable_set(:@code, [1, 2, 3, 4])
			message = "Out of turns! The correct code was 1234."
			expect(STDOUT).to receive(:puts).with(message)
			@game.guesser_loses
		end
	end

	describe "#play_again?" do
		it "returns true if input is Y" do
			expect(STDOUT).to receive(:puts).with("Would you like to play again? [Y/N]")
			allow(@game).to receive(:gets) {"Y"}
			expect(@game.play_again?).to eq(true)
		end

		it "returns false if input is N" do
			expect(STDOUT).to receive(:puts).with("Would you like to play again? [Y/N]")
			allow(@game).to receive(:gets) {"N"}
			expect(@game.play_again?).to eq(false)
		end

		it "shortens input to first letter and capitalizes" do
			expect(STDOUT).to receive(:puts).with("Would you like to play again? [Y/N]")
			allow(@game).to receive(:gets) {"yipNO!"}
			expect(@game.play_again?).to eq(true)
		end
	end



end