#!/bin/bash
clear

echo -e "Traktor v1.9\nTor will be automatically installed and configured…\n\n"

# Install Packages
sudo apt-get update > /dev/null
sudo apt install -y \
	tor \
	obfs4proxy \
	privoxy \
	dnscrypt-proxy \
	torbrowser-launcher \
	apt-transport-tor

# Backup Torrc
if [ -f "/etc/tor/torrc" ]; then
    echo -e "\nBacking up the old torrc to '/etc/tor/torrc.traktor-backup'..."
    sudo cp /etc/tor/torrc /etc/tor/torrc.traktor-backup
fi

# Write Bridge and Config on Torrc
sudo wget https://ubuntu-ir.github.io/traktor/torrc -O /etc/tor/torrc > /dev/null

# Fix Apparmor problem
sudo sed -i '27s/PUx/ix/' /etc/apparmor.d/abstractions/tor
echo ""
sudo apparmor_parser -r -v /etc/apparmor.d/system_tor

# Backup Privoxy Config
if [ -f "/etc/privoxy/config" ]; then
    echo -e "\nBacking up the old privoxy config to '/etc/privoxy/ config-traktor-Backup'..."
    sudo cp /etc/privoxy/config /etc/privoxy/config.traktor-backup
fi 

# Write Privoxy config
sudo perl -i -pe 's/^listen-address/#$&/' /etc/privoxy/config
echo 'logdir /var/log/privoxy
listen-address  0.0.0.0:8118
forward-socks5t             /     127.0.0.1:9050 .
forward         192.168.*.*/     .
forward            10.*.*.*/     .
forward           127.*.*.*/     .
forward           localhost/     .' | sudo tee /etc/privoxy/config > /dev/null
sudo systemctl enable privoxy
sudo systemctl restart privoxy.service

# stop Network Manager from adding dns-servers to /etc/resolv.conf
sudo sed -i -e 's/\[main\]/\[main\]\ndns=none/g' /etc/NetworkManager/NetworkManager.conf

# Set IP and Port on HTTP
gsettings set org.gnome.system.proxy mode 'manual'
gsettings set org.gnome.system.proxy.http host 127.0.0.1
gsettings set org.gnome.system.proxy.http port 8118
gsettings set org.gnome.system.proxy.socks host 127.0.0.1
gsettings set org.gnome.system.proxy.socks port 9050
gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1', '192.168.0.0/16', '192.168.8.1', '10.0.0.0/8', '172.16.0.0/12', '0.0.0.0/8', '10.0.0.0/8', '100.64.0.0/10', '127.0.0.0/8', '169.254.0.0/16', '172.16.0.0/12', '192.0.0.0/24', '192.0.2.0/24', '192.168.0.0/16', '192.88.99.0/24', '198.18.0.0/15', '198.51.100.0/24', '203.0.113.0/24', '224.0.0.0/3']"

# Install Finish
echo -e "\nInstall Finished successfully…\n"

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
echo ""
gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

# Update tor from main repo
echo ""
sudo apt-get update > /dev/null
sudo apt install -y \
	tor \
	obfs4proxy

# Fix Apparmor problem
sudo sed -i '27s/PUx/ix/' /etc/apparmor.d/abstractions/tor
echo ""
sudo apparmor_parser -r -v /etc/apparmor.d/system_tor

# Update & Install finished
echo -e "\n\nCongratulations!!! Your computer is using Tor. may run torbrowser-launcher now."
