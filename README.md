# Linda Enoshima Wind

  * 江ノ島の風をディスプレイする

## 必要な物をインストール

    % gem install bundler
    % bundle install

## Arduinoを接続

  * サーボ
    * 信号 -> Arduino 9番
    * 5VとGNDも繋ぐ
  * TA7291P
    * 1番     -> GND
    * 4,5,6番 -> Arduino 3,4,5番
    * 8番     -> 5V
    * 2,10番  -> DCモータ

## 使用するArduinoを指定

    % export ARDUINO=/dev/tty.usb-device-name

## 実行

    % export LINDA_BASE=http://linda.masuilab.org
    % export LINDA_SPACE=enoshima
    % ruby linda-enoshima-wind.rb
    % ruby linda-enoshima-wind-arduino.rb


## サービスとしてインストール

launchd (for Mac OSX)

    % sudo foreman export launchd /Library/LaunchDaemons/ --app linda-enoshima -u `whoami`
    % sudo launchctl load -w /Library/LaunchDaemons/linda-enoshima-main-1.plist

upstart (for Ubuntu,Debian,Raspberry Pi)

    % sudo foreman export upstart /etc/init/ --app linda-enoshima -d `pwd` -u `whoami`
    % sudo service linda-enoshima start
