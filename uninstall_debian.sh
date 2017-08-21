#!/bin/bash
clear

echo -e "Traktor Debian Uninstaller v1.0\nTraktor will be automatically Removed with Configured…\n\n"

sudo apt purge -y \
	tor \
	obfs4proxy \
	privoxy \
	dnscrypt-proxy \
	torbrowser-launcher \
	apt-transport-tor

sudo apt autoremove -y

sudo rm -rf /etc/apt/sources.list.d/tor.list

sudo apt-key del A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89

sudo sed -i '/dns=none/d' /etc/NetworkManager/NetworkManager.conf

gsettings set org.gnome.system.proxy mode 'none'
gsettings set org.gnome.system.proxy.http host ''
gsettings set org.gnome.system.proxy.http port 0
gsettings set org.gnome.system.proxy.socks host ''
gsettings set org.gnome.system.proxy.socks port 0
gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1']"
