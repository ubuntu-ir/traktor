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

#Commands
GSETTINGS_SET_PROXY_SCHEMA = 'gsettings set org.gnome.system.proxy mode '
GSETTINGS_GET_PROXY_SCHEMA = 'gsettings get org.gnome.system.proxy mode '
RESTART_TOR = 'sudo systemctl restart tor.service'
RESTART_POLIPO = 'service polipo restart'

#Proxy Options (gsettings values)
PROXY_VALUE_NONE = 'none'
PROXY_VALUE_MANUAL = 'manual'

#Messages
MSG_TOR_RELOAD_SUCCESS = "TOR Reloaded Successfully"
MSG_TOR_ACTIVE_SUCCESS = "TOR Activated Successfully"
MSG_SWITCH_TO_NORMAL = "TOR Switched To Normal Mode Successfully"
MSG_FAILUERE = "Something Went Wrong !\n"

#Current Working Directory
cwd = os.path.abspath(os.path.dirname(__file__))

#Icon pathes
ICON_TOR_ON = os.path.join(cwd, 'traktor_gui_panel/photos/tor_proxy_mode.svg')
ICON_TOR_OFF = os.path.join(cwd, 'traktor_gui_panel/photos/tor_normal_mode.svg')



if PROXY_VALUE_MANUAL in ___(GSETTINGS_GET_PROXY_SCHEMA).read():
    indicator = appindicator.Indicator.new(APPINDICATOR_ID, os.path.abspath(ICON_TOR_ON),appindicator.IndicatorCategory.SYSTEM_SERVICES)
else:
    indicator = appindicator.Indicator.new(APPINDICATOR_ID, os.path.abspath(ICON_TOR_OFF),appindicator.IndicatorCategory.SYSTEM_SERVICES)

def main(indicator):
    indicator.set_status(appindicator.IndicatorStatus.ACTIVE)
    indicator.set_menu(build_menu())
    notify.init(APPINDICATOR_ID)
    gtk.main()

def build_menu():
    menu = gtk.Menu()
    item_nm = gtk.MenuItem('Disable Proxy')
    item_nm.connect('activate', nm)
    item_np = gtk.MenuItem('Enable Proxy')
    item_np.connect('activate', np)
    item_rl = gtk.MenuItem('Restart Tor & Polipo')
    item_rl.connect('activate', rl)
    item_quit = gtk.MenuItem('Quit')
    item_quit.connect('activate', quit)
    menu.append(item_nm)
    menu.append(item_np)
    menu.append(item_rl)
    menu.append(item_quit)
    menu.show_all()
    return menu


def fetch(proxy_value, icon_path, msg1):
    msg = ___(GSETTINGS_SET_PROXY_SCHEMA + proxy_value + ";" + RESTART_TOR +"&&" + RESTART_POLIPO).read()
    if msg == "":
        indicator.set_icon(str(os.path.abspath(icon_path)))
        return msg1
    else:
        return MSG_FAILUERE + msg


def fetch_normal_mode():
    return fetch(PROXY_VALUE_NONE, ICON_TOR_OFF, MSG_SWITCH_TO_NORMAL)

def fetch_proxy_mode():
    return fetch(PROXY_VALUE_MANUAL, ICON_TOR_ON, MSG_TOR_ACTIVE_SUCCESS)

def fetch_reload():
    return fetch(PROXY_VALUE_MANUAL, ICON_TOR_ON, MSG_TOR_RELOAD_SUCCESS )


def nm(_):
    notify.Notification.new("<b>Status</b>", fetch_normal_mode(), None).show()

def np(_):
    notify.Notification.new("<b>Status</b>", fetch_proxy_mode(), None).show()

def rl(_):
    notify.Notification.new("<b>Status</b>", fetch_reload(), None).show()

def quit(_):
    notify.uninit()
    gtk.main_quit()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)


main(indicator)
