# -*- encoding: utf-8 -*-
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'arduino_firmata'
require 'eventmachine'
require 'em-rocketio-linda-client'

def scraping
  doc = Nokogiri::HTML(open('http://enoshima-yacht-harbor.jp/kishou.htm'))
  tds= doc.xpath("//td")
  $as = tds[16].xpath(".//b").text.sub(/[^\d\.].*$/,'')
  $ad = tds[19].xpath(".//b").text
  $ms = tds[22].xpath(".//b").text.sub(/[^\d\.].*$/,'')
  $md = tds[25].xpath(".//b").text
  puts "風速 : #{$as.to_f} m, 風向：#{$ad}, (#{Time.now})"
end

EM::run do
  url   =  ENV["LINDA_BASE"]  || ARGV.shift || "http://linda.masuilab.org"
  space =  ENV["LINDA_SPACE"] || "enoshima"
  puts "connecting.. #{url}"
  linda = EM::RocketIO::Linda::Client.new url
  ts = linda.tuplespace[space]

  linda.io.on :connect do
    puts "Linda connect!! <#{linda.io.session}> (#{linda.io.type})"
    scraping
    ts.watch ["wind","random"] do |tuple|
      dir = ["北","北北西","北西","西北西","西","西南西","南西","南南西",
             "南","南南東","南東","東南東","東","東北東","北東","北北東","無風"]
      direction = dir[rand(17)]
      power = (rand * 11).round(1).to_s
      if direction == "無風" or power == "0.0"
        ts.write ["wind","0.0","無風"]
      else
        ts.write ["wind","#{power}","#{direction}"]
      end
    end
  end

  linda.io.on :disconnect do
    puts "RocketIO disconnected.."
  end

  EM::add_periodic_timer 300 do
    scraping
  end

  EM::add_periodic_timer 6 do
    ts.write ["wind",$as,$ad]
  end
end
