#!/bin/bash
clear

echo -e "Traktor v1.2\nTor will be automatically installed and configured…\n\n"

# Install Packages
sudo apt install -y tor obfs4proxy polipo dnscrypt-proxy torbrowser-launcher

# Write Bridge
echo "UseBridges 1
Bridge obfs4 194.132.209.170:36441 B16B4B1B10910B6EC4A3E713297C4EAE9DFB5229 cert=SzdrMUoL49NrQ0WpTy3dw26MlxNAcvD3lLFqZDrAA/euN++77WueeirzoV2OU5QpJplfUQ iat-mode=0
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy" | sudo tee /etc/tor/torrc > /dev/null

# Reload Tor for new torrc to take effect
sudo service tor reload

# Get dist info
DIST=$(lsb_release -sc)

# Add Tor to sources.list to get the latest version
sudo printf \
      "deb http://deb.torproject.org/torproject.org $DIST main \
      \ndeb-src http://deb.torproject.org/torproject.org $DIST main" \
      >> /etc/apt/sources.list.d/tor.list

# Fetching Tor signing key and adding it to the keyring
gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

# Update Tor
sudo torsocks apt update && sudo apt install tor -y

# Fix Problem Apparmor
sudo sed -i '27s/PUx/ix/' /etc/apparmor.d/abstractions/tor
sudo apparmor_parser -r -v /etc/apparmor.d/system_tor

# Write Polipo config
echo 'proxyAddress = "::0"        # both IPv4 and IPv6
allowedClients = 127.0.0.1
socksParentProxy = "localhost:9050"
socksProxyType = socks5' | sudo tee -a /etc/polipo/config > /dev/null
sudo service polipo restart

# Set IP and Port on HTTP
gsettings set org.gnome.system.proxy mode 'manual'
gsettings set org.gnome.system.proxy.http host 127.0.0.1
gsettings set org.gnome.system.proxy.http port 8123

# Install Finish
echo "Install Finished successfully…"
sleep 3
echo -e "Please type '\e[32mtail -f /var/log/tor/log\e[0m to see log." 'but see "\e[31mBootstrapped 100%: Done\e[0m"' "mean tor is \e[92mActive!"
