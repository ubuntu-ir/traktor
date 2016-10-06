#!/bin/bash
clear

echo -e "Tor Auto Installer V1.1\n by Sosha\n\n"

# Read Password
echo "Please enter password"
read -s password

# Waiting...
echo -e "Please Wait to Install Packages...\n"
sleep 3

# Install Packages
sudo apt install tor obfs4proxy polipo dnscrypt-proxy torbrowser-launcher

# Write Bridge
echo "$password" |sudo -S bash -c 'echo -e "UseBridges 1
Bridge obfs4 194.132.209.170:36441 B16B4B1B10910B6EC4A3E713297C4EAE9DFB5229 cert=SzdrMUoL49NrQ0WpTy3dw26MlxNAcvD3lLFqZDrAA/euN++77WueeirzoV2OU5QpJplfUQ iat-mode=0
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy" >> /etc/tor/torrc'

# Fix Problem Apparmor
sudo sed -i '27s/PUx/ix/' /etc/apparmor.d/abstractions/tor
sudo apparmor_parser -r -v /etc/apparmor.d/system_tor

# Write Polipo
echo "$password" |sudo -S bash -c 'echo -e "\nproxyAddress = "::0"        # both IPv4 and IPv6
allowedClients = 127.0.0.1/24
socksParentProxy = "localhost:9050"
socksProxyType = socks5" >> /etc/polipo/config'
sudo service polipo restart

# Set IP and Port on HTTP
gsettings set org.gnome.system.proxy mode 'manual'
gsettings set org.gnome.system.proxy.http host 127.0.0.1
gsettings set org.gnome.system.proxy.http port 8123

# Restart Tor Service
sudo systemctl restart tor.service

# Install Finish
echo "Install Finish..."
sleep 3
echo -e "Please type '\e[32mtail -f /var/log/tor/log\e[0m to see log." 'but see "\e[31mBootstrapped 100%: Done\e[0m"' "mean tor is \e[92mActive!"
