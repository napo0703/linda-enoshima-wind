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
  puts "風速 : #{$as} m, 風向：#{$ad}, (#{Time.now})"
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
  end

  linda.io.on :disconnect do
    puts "RocketIO disconnected.."
  end

  EM::add_periodic_timer 300 do
    scraping
  end

  EM::add_periodic_timer 5 do
    ts.write ["wind",$as,$ad]
  end
end
