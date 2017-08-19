#!/bin/bash
clear

echo -e "Traktor v1.8\nTor will be automatically installed and configured…\n"
function acceptance_agreement()
{ 
    echo "This script is going to install these applications:"
    echo "-------------------------------------------"
    # Applications list
    echo -e " * Tor\n * Obfs4proxy\n * dnscrypt-proxy\n * torbrowser-launcher\n * apt-transport-tor"
    echo "-------------------------------------------"
    echo "Do you agree ?(y/n)"
    read answer
    answer=${answer:-'y'} # set default value as yes
    case $answer in
        y|Y)
            clear
            echo "Start installation..."
            ;;
        n|N)
            echo "Cancel installation and exit..."
            exit 2
            ;;
        *)
            echo "Wrong answer!"
            echo "Exiting..."
            exit
            ;;
    esac
    
}
acceptance_agreement

# Install Packages
sudo apt-get update > /dev/null
sudo apt install -y \
	tor \
	obfs4proxy \
	privoxy \
	dnscrypt-proxy \
	torbrowser-launcher \
	apt-transport-tor

if [ -f "/etc/tor/torrc" ]; then
    echo "Backing up the old torrc to '/etc/tor/torrc.traktor-backup'..."
    sudo cp /etc/tor/torrc /etc/tor/torrc.traktor-backup
fi

# Write Bridge
sudo wget https://ubuntu-ir.github.io/traktor/torrc -O /etc/tor/torrc > /dev/null

# Fix Apparmor problem
sudo sed -i '27s/PUx/ix/' /etc/apparmor.d/abstractions/tor
sudo apparmor_parser -r -v /etc/apparmor.d/system_tor

# Write Privoxy config
sudo perl -i -pe 's/^listen-address/#$&/' /etc/privoxy/config
echo 'logdir /var/log/privoxy
listen-address  0.0.0.0:8118
forward-socks5t             /     127.0.0.1:9050 .
forward         192.168.*.*/     .
forward            10.*.*.*/     .
forward           127.*.*.*/     .
forward           localhost/     .' | sudo tee -a /etc/privoxy/config > /dev/null
sudo systemctl enable privoxy
sudo systemctl restart privoxy.service



# Set IP and Port on HTTP
gsettings set org.gnome.system.proxy mode 'manual'
gsettings set org.gnome.system.proxy.http host 127.0.0.1
gsettings set org.gnome.system.proxy.http port 8118
gsettings set org.gnome.system.proxy.socks host 127.0.0.1
gsettings set org.gnome.system.proxy.socks port 9050
gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1', '192.168.0.0/16', '10.0.0.0/8', '172.16.0.0/12']"

# Install Finish
echo "Install Finished successfully…"

# Wait for tor to establish connection
echo "Tor is trying to establish a connection. This may take long for some minutes. Please wait" | sudo tee /var/log/tor/log
bootstraped='n'
sudo service tor restart
while [ $bootstraped == 'n' ]; do
	if sudo cat /var/log/tor/log | grep "Bootstrapped 100%: Done"; then
		bootstraped='y'
	else
		sleep 1
	fi
done

# Add tor repos
echo "deb tor+http://deb.torproject.org/torproject.org stable main" | sudo tee /etc/apt/sources.list.d/tor.list > /dev/null
echo "deb tor+http://deb.torproject.org/torproject.org obfs4proxy main" | sudo tee -a /etc/apt/sources.list.d/tor.list > /dev/null

# Fetching Tor signing key and adding it to the keyring
gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

# update tor from main repo
sudo apt-get update > /dev/null
sudo apt install -y \
	tor \
	obfs4proxy

# Fix Apparmor problem
sudo sed -i '27s/PUx/ix/' /etc/apparmor.d/abstractions/tor
sudo apparmor_parser -r -v /etc/apparmor.d/system_tor

# Traktor GUI Panel 
mkdir $HOME/.traktor_gui_panel
mv traktor_gui_panel.py $HOME/.traktor_gui_panel 
mv traktor_gui_panel/icons $HOME/.traktor_gui_panel/
chmod +x ~/.traktor_gui_panel/traktor_gui_panel.py

sudo touch /usr/share/applications/traktor-gui-panel.desktop 
echo "[Desktop Entry]
Version=1.0
Name=Traktor GUI Panel
Name[fa]=تراکتور پنل گرافیکی
GenericName=Traktor Panel
GenericName[fa]=تراکتور پنل
Comment=Traktor GUI Panel
Comment[fa]=تراکتور پنل گرافیکی
Exec=$HOME/.traktor_gui_panel/traktor_gui_panel.py
Terminal=false
Type=Application
Categories=Network;Application;
Icon=$HOME/.traktor_gui_panel/icons/traktor.png
Keywords=Tor;Browser;Proxy;VPN;Internet;Web" | sudo tee /usr/share/applications/traktor-gui-panel.desktop > /dev/null

# update finished
echo "Congratulations!!! Your computer is using Tor. may run torbrowser-launcher now."
