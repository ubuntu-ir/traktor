#!/bin/bash
clear
#add repositories
sudo zypper addrepo http://download.opensuse.org/repositories/home:hayyan71/openSUSE_Leap_42.2/home:hayyan71.repo #add obfs4proxy
sudo zypper addrepo http://download.opensuse.org/repositories/server:proxy/openSUSE_Leap_42.2/server:proxy.repo #add privoxy
sudo zypper addrepo http://download.opensuse.org/repositories/server:dns/openSUSE_42.2/server:dns.repo #add dnscrypt-proxy
sudo zypper --no-gpg-checks ref
#Install Packages
sudo zypper in -l -y obfs4proxy dnscrypt-proxy privoxy

if [ -f "/etc/tor/torrc" ]; then
    echo "Backing up the old torrc to '/etc/tor/torrc.traktor-backup'..."
    sudo cp /etc/tor/torrc /etc/tor/torrc.traktor-backup
fi

# Write Bridge
sudo wget https://ubuntu-ir.github.io/traktor/torrc -O /etc/tor/torrc > /dev/null
sudo sed -i -- 's/Log notice file \/var\/log\/tor\/log/Log notice file \/var\/log\/tor\/tor.log/g' /etc/tor/torrc

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

if [ -f "/usr/share/xsessions/plasma5.desktop" ] #KDE Plasma5
then
    ##need more commits
    ##use proxy in shell
    #sudo sed -i -- 's/PROXY_ENABLED="no"/PROXY_ENABLED="yes"/g' /etc/sysconfig/proxy
    #sudo sed -i -- 's/HTTP_PROXY=""/HTTP_PROXY="http:\/\/127.0.0.1:8118"/g' /etc/sysconfig/proxy
    #sudo sed -i -- 's/SOCKS_PROXY=""/SOCKS_PROXY="socks:\/\/127.0.0.1:9050"/g' /etc/sysconfig/proxy
else #gnome
    settings set org.gnome.system.proxy mode 'manual'
    gsettings set org.gnome.system.proxy.http host 127.0.0.1
    gsettings set org.gnome.system.proxy.http port 8118
    gsettings set org.gnome.system.proxy.socks host 127.0.0.1
    gsettings set org.gnome.system.proxy.socks port 9050
    gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1', '192.168.0.0/16', '10.0.0.0/8', '172.16.0.0/12']"
fi

    
# Wait for tor to establish connection
echo "Tor is trying to establish a connection. This may take long for some minutes. Please wait" | sudo tee /var/log/tor/log
bootstraped='n'
sudo service tor restart
while [ $bootstraped == 'n' ]; do
	if sudo cat /var/log/tor/tor.log | grep "Bootstrapped 100%: Done"; then
		bootstraped='y'
		echo "if you are using KDE , set IP and PORT manualy"
	else
		sleep 1
	fi
done
