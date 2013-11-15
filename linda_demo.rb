# -*- encoding: utf-8 -*-
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'eventmachine'
require 'em-rocketio-linda-client'

EM::run do
  url   =  ENV["LINDA_BASE"]  || ARGV.shift || "http://linda.masuilab.org"
  space =  ENV["LINDA_SPACE"] || "enoshima"
  puts "connecting.. #{url}"
  linda = EM::RocketIO::Linda::Client.new url
  ts = linda.tuplespace[space]

  linda.io.on :connect do
    puts "Linda connect!! <#{linda.io.session}> (#{linda.io.type})"
  end

  linda.io.on :disconnect do
    puts "RocketIO disconnected.."
  end

  EM::add_periodic_timer 5 do
    dir = ["北","北北西","北西","西北西","西","西南西","南西","南南西",
           "南","南南東","南東","東南東","東","東北東","北東","北北東","無風"]
    direction = dir[rand(17)]
    power = (rand * 11).round(1)
    if direction == dir[16] || power == 0.0
      power = 0.0
      ts.write ["wind",power,direction]
      puts "[wind,#{power},#{direction}]"
    else
      ts.write ["wind",power,direction]
      puts "[wind,#{power},#{direction}]"
    end
  end
end
