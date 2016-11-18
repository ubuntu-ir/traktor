#!/bin/bash

# License : GPLv3+

#Checking if the distro is debianbase / archbase  and running the correct script
if pacman -Q &> /dev/null ;then
  if [ ! -f ./traktor_arch.sh ]; then
    wget -O ./traktor_arch.sh 'https://raw.githubusercontent.com/ubuntu-ir/traktor/master/traktor_arch.sh' || curl -O  https://raw.githubusercontent.com/ubuntu-ir/traktor/master/traktor_arch.sh
  fi
  sudo chmod +x ./traktor_arch.sh
 ./traktor_arch.sh
  # echo "arch"
elif apt list --installed &> /dev/null ;then
  if [ ! -f ./traktor_debian.sh ]; then
    wget -O ./traktor_debian.sh 'https://raw.githubusercontent.com/ubuntu-ir/traktor/master/traktor_debian.sh' || curl -O  https://raw.githubusercontent.com/ubuntu-ir/traktor/master/traktor_debian.sh
  fi
  sudo chmod +x ./traktor_debian.sh
  ./traktor_debian.sh
  # echo "debian"
else
    echo "Your distro is neither archbase nor debianbase So, The script is not going to work in your distro."
fi
