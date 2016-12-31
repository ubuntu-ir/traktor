#!/usr/bin/python

import os
import signal
import gi

gi.require_version('Gtk','3.0')
gi.require_version('AppIndicator3','0.1')
gi.require_version('Notify','0.7')

from gi.repository import Gtk, Gio, Notify
from gi.repository import AppIndicator3 as appindicator
from gettext import gettext as T

from os import popen #TODO remove dependency

APPINDICATOR_ID = 'traktor'
Name = T("Traktor")

#Commands #TODO remove bash commands
RESTART_TOR = 'sudo systemctl restart tor.service'

#Current Working Directory #TODO Move to /usr/share/traktor/icons
cwd = os.path.abspath(os.path.dirname(__file__))

#Icon pathes
ICON_TOR_ON = os.environ.get("HOME") + "/.traktor_gui_panel/icons/tor_proxy_mode.svg"
ICON_TOR_OFF = os.environ.get("HOME") + "/.traktor_gui_panel/icons/tor_normal_mode.svg"

proxy = Gio.Settings.new("org.gnome.system.proxy")
if (Gio.Settings.get_string(proxy, "mode")=="manual"):
    indicator = appindicator.Indicator.new(APPINDICATOR_ID,ICON_TOR_ON,appindicator.IndicatorCategory.SYSTEM_SERVICES)
else:
    indicator = appindicator.Indicator.new(APPINDICATOR_ID,ICON_TOR_OFF,appindicator.IndicatorCategory.SYSTEM_SERVICES)

def main(indicator):
    indicator.set_status(appindicator.IndicatorStatus.ACTIVE)
    indicator.set_menu(build_menu())
    Notify.init(APPINDICATOR_ID)
    Gtk.main()

def build_menu():
    menu = Gtk.Menu()
    
    img_proxy = Gtk.Image()
    img_proxy.set_from_file(os.environ.get("HOME") + "/.traktor_gui_panel/icons/tor_proxy_mode.svg")
    item_proxy = Gtk.ImageMenuItem('Enable Proxy')
    item_proxy.set_image(img_proxy)
    item_proxy.set_always_show_image(True)
    item_proxy.connect('activate', proxy_mode)
    
    img_normal = Gtk.Image()
    img_normal.set_from_file(os.environ.get("HOME") + "/.traktor_gui_panel/icons/tor_normal_mode.svg")
    item_normal = Gtk.ImageMenuItem('Disable Proxy')
    item_normal.set_image(img_normal)
    item_normal.set_always_show_image(True)
    item_normal.connect('activate', normal_mode)

    img_start = Gtk.Image()
    img_start.set_from_file(os.environ.get("HOME") + "/.traktor_gui_panel/icons/tor_proxy_mode_reload.svg")
    item_start = Gtk.ImageMenuItem('Restart Tor')
    item_start.set_image(img_start)
    item_start.set_always_show_image(True)
    item_start.connect('activate', restart)
    
    img_quit = Gtk.Image()
    img_quit.set_from_file()
    item_quit = Gtk.ImageMenuItem('Quit')
    item_quit.set_image(img_quit)
    item_quit.set_always_show_image(True)
    item_quit.connect('activate', quit)
    
    menu.append(item_proxy)
    menu.append(item_normal)
    menu.append(item_start)
    menu.append(item_quit)
    
    menu.show_all()
    
    return menu

def normal_mode(_):
    proxy.set_string("mode", "none")
    indicator.set_icon(str(os.path.abspath(ICON_TOR_OFF)))
    Notify.Notification.new(Name, T("Switched to normal mode"), None).show()

def proxy_mode(_):
    proxy.set_string("mode", "manual")
    proxy.set_strv("ignore-hosts", ['localhost', '127.0.0.0/8', '::1', '192.168.0.0/16', '10.0.0.0/8', '172.16.0.0/12'])
    http = Gio.Settings.new("org.gnome.system.proxy.http")
    http.set_string("host", "127.0.0.1")
    http.set_int("port", 8123)
    socks = Gio.Settings.new("org.gnome.system.proxy.socks")
    socks.set_string("host", "127.0.0.1")
    socks.set_int("port", 9050)
    indicator.set_icon(str(os.path.abspath(ICON_TOR_ON)))
    Notify.Notification.new(Name, T("Tor activated"), None).show()

def restart(_):
    msg = popen(RESTART_TOR).read() #TODO write in pure python
    if msg == "":
        Notify.Notification.new(Name, T("Tor restarted"), None).show()
    else:
        Notify.Notification.new(Name, T("Something went wrong. See the log"), None).show()

def quit(_):
    Notify.uninit()
    Gtk.main_quit()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)

main(indicator)
