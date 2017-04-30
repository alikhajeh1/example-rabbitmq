#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

# Start a communication session with RabbitMQ
conn = Bunny.new(ENV['RABBITMQ_URI'])
conn.start

# open a channel
ch = conn.create_channel

# declare a queue
q  = ch.queue("test1", durable: true)

i = 1
while true
  # publish a message to the default exchange which then gets routed to this queue
  q.publish("Hello world! - MESSAGE COUNT #{i}")

  # fetch a message from the queue
  delivery_info, metadata, payload = q.pop

  puts "MESSAGE: #{payload}"
  # Ensure the output is flushed to the logs
  STDOUT.flush
  i += 1
  sleep 5
end

# close the connection
conn.stop
