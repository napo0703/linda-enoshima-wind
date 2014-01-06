# -*- encoding: utf-8 -*-
require 'rubygems'
require 'eventmachine'
require 'em-rocketio-linda-client'
$stdout.sync = true

EM::run do
  url   =  ENV["LINDA_BASE"]  || ARGV.shift || "http://linda.masuilab.org"
  space =  ENV["LINDA_SPACE"] || "delta"
  puts "Linda connecting.. #{url}"
  linda = EM::RocketIO::Linda::Client.new url
  ts = linda.tuplespace[space]

  linda.io.on :connect do
    puts "Linda connect!! <#{linda.io.session}> (#{linda.io.type})"
    ts.watch ["sensor","temperature"] do |tuple|
      p tuple[2]
      if tuple[2] >= 25
        arduino.digital_write 5,false
        arduino.digital_write 4,true
        arduino.analog_write 3,255
      else
        arduino.digital_write 5,true
        arduino.digital_write 4,false
        arduino.analog_write 3,255
      end
    end
  end

  linda.io.on :disconnect do
    puts "RocketIO disconnected.."
  end
end
