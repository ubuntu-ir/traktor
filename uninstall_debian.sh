#!/bin/bash

echo -e "Traktor v1.6\nTor will be automatically uinstalled ...\n\n"

sudo apt remove -y \
	tor \
	obfs4proxy \
	privoxy \
	dnscrypt-proxy \
	torbrowser-launcher \
	apt-transport-tor

sudo rm -f /etc/tor/torrc \
	/etc/apparmor.d/abstractions/tor \
	/etc/apparmor.d/system_tor &> /dev/null

gsettings set org.gnome.system.proxy mode 'auto'

sudo rm -f /etc/apt/sources.list.d/tor.list &> /dev/null

sudo rm -f /usr/share/applications/traktor_gui_panel.desktop > /dev/null
sudo rm -f ~/.traktor_gui_panel

gpg --delete-keys A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
# User should enter 'y' to delete the public key from keyring.

echo "Uninstalling Finished Successfully." 
