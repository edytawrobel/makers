require 'socket'


#takes a chatter - a socket object as its argument
def welcome(chatter)
  chatter.print "Welcome! Please enter your name: "
  chatter.readline.chomp  #returns a line of client input
end

#a heart of the chat functionality.
def broadcast(message, chatters)
  chatters.each do |chatter| #Goes through an array of chatters
    chatter.puts message #sends a message to each one (new client joined the chat)
  end
end

s = TCPServer.new(3939) #instantiation of the server
  chatters = [] #initializiation of the array of chatters

while (chatter = s.accept) #when a chatter connects
  Thread.new(chatter) do |c|
    name = welcome(chatter)
    broadcast("#{name} has joined", chatters) #notify chatters new client has arrived
    chatters << chatter #new chatter added to chatters array, it will be included in future message broadcasts
    #chatting part
    #accept messages from this client forever but to take action if the client socket reports end-of-file
    begin
      loop do
        line = c.readline #readline rises the exception on end-of-file
        broadcast("#{name}: #{line}", chatters)
      end
    rescue EOFError
      c.close
      chatters.delete(c) #departed chatter removed from the array
      broadcast("#{name} has left", chatters) #announcement that he's left
    end
  end
end
