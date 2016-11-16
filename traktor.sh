#!/bin/bash 

# License : GPLv3+

#Checking if the distro is debianbase / archbase  and running the correct script
if [ "pacman -Q" ];then
 ./traktor_arch.sh
#    echo "arch"
elif [ "apt list --installed"  ];then
   ./traktor_debian.sh
#    echo "debian"
else
    echo "Your distro is neither archbase nor debianbase So, The script is not going to work in your distro."
fi
