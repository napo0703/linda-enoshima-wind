require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'linda-socket.io-client'
require 'eventmachine'

linda = Linda::SocketIO::Client.connect 'http://linda-server.herokuapp.com'
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
  $value = "#{$ad} #{$as}m/s"
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
    ts.write(
      wakaruland: "data",
      from: "enoshima_wind",
      value: $value,
      displaytime: "20",
      time: Time.now,
      background: "https://i.gyazo.com/d13f222ba330bf686b6cdcd98b264464.png",
      onclick: {
        where: "delta",
        type: "say",
        value: "江ノ島の風、#{$ad}、#{$as}メートル"
      })
  end
end
