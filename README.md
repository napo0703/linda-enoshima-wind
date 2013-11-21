# Linda Enoshima Wind
  
  * 江ノ島の風をディスプレイする

## 必要な物をインストール

    % gem install bundler
    % bundle install

## Arduinoを接続

  * サーボ -> Arduino 9番
    * 5VとGNDも繋ぐ
  * TA7291P -> Arduino 3,4,5番
    * 5V -> TA7291P 8番
    * GND -> TA7291P 1番
    * DCモータ -> TA7291P 2,10番

## 使用するArduinoを指定

    % export ARDUINO=/dev/tty.usb-device-name

## 実行

    % export LINDA_BASE=http://linda.masuilab.org
    % export LINDA_SPACE=enoshima
    % ruby linda.rb
    % ruby arduino.rb


## サービスとしてインストール

launchd (Mac OSX用)

    % sudo foreman export launchd /Library/LaunchDaemons/ --app linda-enoshima -u `whoami`
    % sudo launchctl load -w /Library/LaunchDaemons/linda-enoshima-main-1.plist

upstart (Ubuntu/Debian/RaspberryPi用)

    % sudo foreman export upstart /etc/init/ --app linda-enoshima -d `pwd` -u `whoami`
    % sudo service linda-enoshima start
