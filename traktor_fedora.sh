#!/bin/bash
clear

echo -e "Traktor v1.8\nTor will be automatically installed and configured…\n\n"
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
sudo dnf install -y  \
	tor \
	privoxy \
	dnscrypt-proxy \
        torbrowser-launcher \

sudo dnf install -y \
         make \
         automake \
         gcc \
         python-pip \
         python-devel \
         libyaml-devel \
         redhat-rpm-config

# sudo pip install obfsproxy
sudo dnf install -y obfs4

if [ -f "/etc/tor/torrc" ]; then
    echo "Backing up the old torrc to '/etc/tor/torrc.traktor-backup'..."
    sudo cp /etc/tor/torrc /etc/tor/torrc.traktor-backup
fi


#configuring dnscrypt-proxy
sudo wget https://ubuntu-ir.github.io/traktor/dnscrypt-proxy.service-fedora -O /etc/systemd/system/dnscrypt.service > /dev/null
sudo systemctl daemon-reload
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf >/dev/null
#sudo chattr +i /etc/resolv.conf
sudo systemctl enable dnscrypt.service
sudo systemctl start dnscrypt.service

# Write Bridge
sudo wget https://ubuntu-ir.github.io/traktor/torrcV3 -O /etc/tor/torrc > /dev/null

# Change tor log file owner

sudo touch /var/log/tor/log
sudo chown toranon:toranon /var/log/tor/log


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



# Set IP and Port on HTTP and SOCKS
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
sudo systemctl enable tor.service
sudo systemctl restart tor.service
while [ $bootstraped == 'n' ]; do
	if sudo cat /var/log/tor/log | grep "Bootstrapped 100%: Done"; then
		bootstraped='y'
	else
		sleep 1
	fi
done

# update finished
echo "Congratulations!!! Your computer is using Tor. may run torbrowser-launcher now."
