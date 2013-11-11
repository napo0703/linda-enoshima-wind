# -*- encoding: utf-8 -*-
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'arduino_firmata'
require 'eventmachine'
require 'em-rocketio-linda-client'
$stdout.sync = true

EM::run do
  arduino = ArduinoFirmata.connect ENV["ARDUINO"], :eventmachine => true
  puts "Arduino connect!! (firmata version v#{arduino.version})"
  url   =  ENV["LINDA_BASE"]  || ARGV.shift || "http://linda.masuilab.org"
  space =  ENV["LINDA_SPACE"] || "enoshima"
  puts "Linda connecting.. #{url}"
  linda = EM::RocketIO::Linda::Client.new url
  ts = linda.tuplespace[space]

  linda.io.on :connect do
    puts "Linda connect!! <#{linda.io.session}> (#{linda.io.type})"
    ts.watch ["wind"] do |tuple|
      p tuple
      dir = ["北","北北西","北西","西北西","西","西南西","南西","南南西",
             "南","南南東","南東","東南東","東","東北東","北東","北北東"]

      direction = dir.index(tuple[2]) * 5
      power = tuple[1].round * 18 + 75
      p "角度 #{dir.index(tuple[2]) * 22.5}" + " 風速 #{power}"

      arduino.servo_write 9,direction #サーボ
      arduino.digital_write 5,false   #DCモータ
      arduino.digital_write 4,true
      arduino.analog_write 3,power
    end
  end

  linda.io.on :disconnect do
    puts "RocketIO disconnected.."
  end
end
