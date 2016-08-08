require "sinatra"
require "sinatra/reloader" if development?
require_relative "lib/mastermind.rb"

get "/" do
	erb :index
end

post "/name" do
	erb :name
end

post "/role" do
	name = params["name"]
	@@game = Mastermind.new(name)
	erb :role
end

post "/coder" do
	erb :coder
end

post "/game" do
	@@code = params["code"].upcase.chars.delete_if { |n| [" ", ","].include?(n) }
	if @@code.length != 4 || !(@@code.all? {|n| ["R", "G", "B", "Y", "P", "V"].include?(n)})
		erb :coder
	else
		@@game.player.code(@@code)
		redirect to("/game")
	end
end

get "/game" do
	if @@game.computer_win?
		notice = @@game.computer_victory
		list = @@game.computer.guesses.join(", ")
		erb :end, :locals => { :notice => notice, :list => list }
	elsif !@@game.lose?
		guess = @@game.computer.guesses.join(", ")
		erb :game, :locals => { :guess => guess }
	else
		notice = @@game.loss
		erb :end, :locals => { :notice => notice }
	end
end

post "/feedback" do
	feedback = params["feedback"].upcase.chars.delete_if { |n| [" ", ","].include?(n) }
	@@game.player.give_hint(feedback)
	@@game.turn
	@@game.human_hint
	@@game.computer.convert(@@game.computer.guesses)
	redirect to("/game")
end

post "/guesser" do
	redirect to("/game1")
end

get "/game1" do
	if @@game.human_win?
		notice = @@game.human_victory
		erb :end, :locals => { :notice => notice }
	elsif @@game.lose?
		notice = @@game.loss
		erb :end, :locals => { :notice => notice }
	else
		list = @@game.board.all
		erb :game1, :locals => { :list => list }
	end
end

post "/guess" do
	guess = params["guess"].upcase.chars.delete_if { |n| [" ", ","].include?(n) }
	if guess.length != 4 || !(guess.all? {|n| ["R", "G", "B", "Y", "P", "V"].include?(n)})
		redirect to("/game1")
	else
		@@game.player.pick(guess)
		@@game.turn
		@@game.computer_hint
		@@game.board_change
		@@game.board.set(@@game.player.choice)
		@@game.board.whole
		redirect to("/game1")
	end
end