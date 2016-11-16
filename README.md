# traktor
Traktor will autamically install Tor, polipo, dnscrypt-proxy and Tor Browser Launcher in a Arch Linux based 
distro like Arch Linux, Manjaro,... and configures them as well.

To do this, just run 'traktor.sh' file in a supported shell like bash and watch for prompts it asks you.

## Note
Do NOT expect anonymity using this method. Polipo is an http proxy and can leak data. If you need anonymity or strong privacy, manually run torbrowser-launcher after installing traktor and use it.

## Install
    wget https://github.com/AmirrezaFiroozi/traktor/archive/master.zip -O traktor.zip
    unzip traktor.zip && cd traktor-master
    ./traktor.sh


## Remote install
type in bash:

    curl -s https://raw.githubusercontent.com/AmirrezaFiroozi/traktor/master/traktor.sh | sh
