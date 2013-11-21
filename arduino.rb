# -*- encoding: utf-8 -*-
require 'rubygems'
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
      dir = ["北","北北東","北東","東北東","東","東南東","南東","南南東",
             "南","南南西","南西","西南西","西","西北西","北西","北北西","無風"]
      next if tuple.size != 3

      # 16方位以外はだめ
      for i in 0..16 do
        if tuple[2] == dir[i]
          flag = 1
          break
        end
      end

      # 風速は0~50までの値しかだめ
      if flag == 1 && tuple[1].to_f >= 0.0 && tuple[1].to_f < 50.0
        if tuple[2] == dir[16]  # 無風のとき
          arduino.digital_write 5,false
          arduino.digital_write 4,false
          arduino.digital_write 3,0
        else
          #direction = dir.index(tuple[2]) * 22.5 # 本来ならばこれ
          direction = dir.index(tuple[2]) * 4.8   # サーボが特殊なため
          power = tuple[1].to_i * 10 + 65 # 25以上でないと風車が動かない
          if power > 255 # 風速10m/s以上のとき
            power = 255
          end
          p "角度：#{dir.index(tuple[2]) * 22.5}度、" + "風力：#{power}"
          arduino.servo_write 9,direction.round #サーボ
          arduino.digital_write 5,false #DCモータ
          arduino.digital_write 4,true
          #arduino.analog_write 3,255 # 風車の動き出しに勢いをつける
          #sleep 0.1
          arduino.analog_write 3,power.round
        end
      end
    end
  end

  linda.io.on :disconnect do
    puts "RocketIO disconnected.."
  end
end
