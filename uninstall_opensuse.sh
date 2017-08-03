clear
echo -e "Traktor\nTor will be automatically uinstalled ...\n\n"
sudo zypper rr server_dns home:hayyan71
sudo zypper rm -y obfs4proxy tor torsocks dnscrypt-proxy privoxy 
sudo rm -f /etc/tor/torrc 
gsettings set org.gnome.system.proxy mode 'none'
echo "Uninstalling Finished Successfully."
exit 0
