# This projects is dropped. Please use [Traktor new generation](https://gitlab.com/danialbehzadi/traktor-ng) which is available via PPA too.

Traktor will autamically install Tor, privoxy, dnscrypt-proxy and Tor Browser Launcher in either a Debian based distro like Ubuntu or an Arch based distro and configures them as well.

To do this, just run 'traktor.sh' file in a supported shell like bash and watch for prompts it asks you.

## Note
Do NOT expect anonymity using this method. Privoxy is an http proxy and can leak data. If you need anonymity or strong privacy, manually run torbrowser-launcher after installing traktor and use it.

## Install
### Ubuntu
    sudo add-apt-repository ppa:dani.behzi/traktor
    sudo apt update
    sudo apt install traktor
### ArchLinux
    yaourt -S traktor
### Other (May not be able to install yet)
    wget https://github.com/ubuntu-ir/traktor/archive/master.zip -O traktor.zip
    unzip traktor.zip && cd traktor-master
    ./traktor.sh

## Remote update
    curl -s https://raw.githubusercontent.com/ubuntu-ir/traktor/master/traktor.sh | sh
    
## Changes
    Version 1.6:
        1. fix tor icons
        2. add new obfs3 bridges
        3. add new obfs4 bridges
        4. backup torrc file
        5. add privoxy package
        6. remove polipo package
        7. change port

    Verion 1.7:
        1. traktor is now supporting fedora
        2. add traktor_fedora.sh file
        3. remove unistall_debian.sh file
        4. remove traktor_gui_panel folder
    
    Version 1.8:
        1. traktor is now supporting OpenSUSE
        2. add traktor_opensuse.sh
