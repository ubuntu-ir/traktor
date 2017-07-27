#!/bin/bash
while getopts ":u" options; do
    case $options in 
    u)
    	clear
        echo -e "Traktor\nTor will be automatically uinstalled ...\n\n"
        sudo zypper rr server_dns server_proxy home:hayyan71
        sudo zypper rm obfs4proxy tor torsocks dnscrypt-proxy privoxy 
        sudo rm -f /etc/tor/torrc 
        gsettings set org.gnome.system.proxy mode 'auto'
        echo "Uninstalling Finished Successfully."
        exit 0
    ;;
    esac
done

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
sudo sed -i '1 i\SOCKSPolicy accept 127.0.0.1:9050' /etc/tor/torrc
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

if [ -f "/usr/share/xsessions/plasma5.desktop" ]; then
    echo
    #KDE Plasma5
    ##need more commits
    ##use proxy in shell
    #sudo sed -i -- 's/PROXY_ENABLED="no"/PROXY_ENABLED="yes"/g' /etc/sysconfig/proxy
    #sudo sed -i -- 's/HTTP_PROXY=""/HTTP_PROXY="http:\/\/127.0.0.1:8118"/g' /etc/sysconfig/proxy
    #sudo sed -i -- 's/SOCKS_PROXY=""/SOCKS_PROXY="socks:\/\/127.0.0.1:9050"/g' /etc/sysconfig/proxy
else 
    #gnome
    gsettings set org.gnome.system.proxy mode 'manual'
    gsettings set org.gnome.system.proxy.http host 127.0.0.1
    gsettings set org.gnome.system.proxy.http port 8118
    gsettings set org.gnome.system.proxy.socks host 127.0.0.1
    gsettings set org.gnome.system.proxy.socks port 9050
    gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1', '192.168.0.0/16', '192.168.8.1', '10.0.0.0/8', '172.16.0.0/12', '0.0.0.0/8', '10.0.0.0/8', '100.64.0.0/10', '127.0.0.0/8', '169.254.0.0/16', '172.16.0.0/12', '192.0.0.0/24', '192.0.2.0/24', '192.168.0.0/16', '192.88.99.0/24', '198.18.0.0/15', '198.51.100.0/24', '203.0.113.0/24', '224.0.0.0/3']"
fi

    
# Wait for tor to establish connection
echo "Tor is trying to establish a connection. This may take long for some minutes. Please wait" | sudo tee /var/log/tor/log
bootstraped='n'
sudo service tor restart
while [ $bootstraped == 'n' ]; do
	if sudo cat /var/log/tor/tor.log | grep "Bootstrapped 100%: Done"; then
		bootstraped='y'
		echo "if you are using KDE , set IP and PORT manually"
	else
		sleep 1
	fi
done
