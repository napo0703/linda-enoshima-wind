require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'linda-socket.io-client'
require 'eventmachine'

linda = Linda::SocketIO::Client.connect 'http://wakaruland-linda.herokuapp.com'
ts = linda.tuplespace('masuilab')

def getWind
  doc = Nokogiri::HTML(open('http://www.s-n-p.jp/kishou.htm'))
  tds = doc.xpath("//td")
  $as = tds[16].xpath(".//b").text.sub(/[^\d\.].*$/,'')
  $ad = tds[19].xpath(".//b").text
  #$ms = tds[22].xpath(".//b").text.sub(/[^\d\.].*$/,'')
  #$md =  tds[25].xpath(".//b").text
  #cmd = "#{$as} #{$ad} #{$ms} #{$md} (#{Time.now})"
  puts "風速: #{$as}m/s, 風向: #{$ad} (#{Time.now})"
end

EM::run do
  puts "connecting..."

  linda.io.on :connect do
    puts "connect!!"
    getWind
  end

  linda.io.on :disconnect do
    puts "disconnected..."
  end

  EM::add_periodic_timer 600 do
    getWind
  end

  EM::add_periodic_timer 10 do
    ts.write(where: "enoshima", type: "web", name: "wind", direction: $ad, speed: $as.to_f)
  end
end
