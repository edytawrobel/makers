require 'socket'
require_relative 'rps'

s = TCPServer.new(3939)
threads = []

#not looping forever, but gather only two threads
2.times do |n|
  conn = s.accept
  threads << Thread.new(conn) do |c|
    #for each of the two connections, create a thread
    Thread.current[:number] = n + 1  #adding one so there is no player zero
    Thread.current[:player] = c
    c.puts "Welcome, player #{n + 1}!"
    c.print "Your move? (rock, paper, scissors) "
    Thread.current[:move] = c.gets.chomp
    c.puts "Thanks... hang on"
  end
end

#after both players have played, we grab the two threads in variable and join both threads
a,b = threads
a.join
b.join

#create two rps objects
rps1, rps2 = Games::RPS.new(a[:move]), Games::RPS.new(b[:move])

#playing the objects against each other
#final result is either the winner, or if the game returned false, a tie

winner = rps1.play(rps2)
if winner
  result = winner.move
else
  result = "tie!"
end

#report the results to both players
threads.each do |t|
  t[:player].puts "The winner is #{result}!"
end
