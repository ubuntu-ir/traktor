#!/usr/bin/python

import os
import signal
import gi

gi.require_version('Gtk','3.0')
gi.require_version('AppIndicator3','0.1')
gi.require_version('Notify','0.7')

from gi.repository import Gtk as gtk
from gi.repository import AppIndicator3 as appindicator
from gi.repository import Notify as notify

from os import popen as ___

APPINDICATOR_ID = 'traktor'

if 'manual' in ___('gsettings get org.gnome.system.proxy mode').read():
    indicator = appindicator.Indicator.new(APPINDICATOR_ID, os.path.abspath('.traktor_gui_panel/photos/tor_np.svg'),appindicator.IndicatorCategory.SYSTEM_SERVICES)
else:
    indicator = appindicator.Indicator.new(APPINDICATOR_ID, os.path.abspath('.traktor_gui_panel/photos/tor_nm.svg'),appindicator.IndicatorCategory.SYSTEM_SERVICES)

def main(indicator):
    indicator.set_status(appindicator.IndicatorStatus.ACTIVE)
    indicator.set_menu(build_menu())
    notify.init(APPINDICATOR_ID)
    gtk.main()

def build_menu():
    menu = gtk.Menu()
    item_nm = gtk.MenuItem('Normal Mode (Browser)')
    item_nm.connect('activate', nm)
    item_np = gtk.MenuItem('Network Proxy')
    item_np.connect('activate', np)
    item_rl = gtk.MenuItem('Reload')
    item_rl.connect('activate', rl)
    item_quit = gtk.MenuItem('Quit')
    item_quit.connect('activate', quit)
    menu.append(item_nm)
    menu.append(item_np)
    menu.append(item_rl)
    menu.append(item_quit)
    menu.show_all()
    return menu

def fetch_nm():
    msg = ___("gsettings set org.gnome.system.proxy mode 'none'; sudo systemctl restart tor.service && service polipo restart").read()
    if msg == "":
        indicator.set_icon(str(os.path.abspath('.traktor_gui_panel/photos/tor_nm.svg')))
        return "TOR switch to normal mode successfully" 
    else:
        return "Something went wrong..!\n" + msg

def fetch_np():
    msg = ___("gsettings set org.gnome.system.proxy mode 'manual'; sudo systemctl restart tor.service && service polipo restart").read()
    if msg == "":
        indicator.set_icon(str(os.path.abspath('.traktor_gui_panel/photos/tor_np.svg')))
        return "TOR activated successfully"
    else:
        return "Something went wrong..!\n" + msg 

def fetch_rl():
    msg = ___("gsettings set org.gnome.system.proxy mode 'manual'; sudo systemctl restart tor.service && service polipo restart").read()
    if msg == "":
        indicator.set_icon(str(os.path.abspath('.traktor_gui_panel/photos/tor_np.svg')))
        return "TOR reload successfully"
    else:
        return "Something went wrong..!\n" + msg 

def nm(_):
    notify.Notification.new("<b>Status</b>", fetch_nm(), None).show()

def np(_):
    notify.Notification.new("<b>Status</b>", fetch_np(), None).show()

def rl(_):
    notify.Notification.new("<b>Status</b>", fetch_rl(), None).show()

def quit(_):
    notify.uninit()
    gtk.main_quit()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)


main(indicator)
