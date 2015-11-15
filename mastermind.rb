class Mastermind
	def initialize
		generate_code
		introduction
		@correct_guess = false
		play
	end

	def generate_code
		@code = []
		4.times do |x|
			@code << rand(1..6)			
		end
	end

	def introduction
		puts "--------Welcome to Mastermind--------"
	end

	def play
		@turn_count = 0
		while !@correct_guess && @turn_count < 12
			@turn_count += 1
			puts "Enter your guess:"
			@guess = gets.chomp.split("")
			while @guess.count != 4 || (@guess.all?{|x| (1..6).include? x.to_i}) == false
				puts "Please enter a valid combination. (4 digits, each between 1 and 6)."
				p @guess.all?{|x| (1..6).include? x.to_i}
				@guess = gets.split("")
			end
			p "VALID!"
		end
	end

	
end

game = Mastermind.new