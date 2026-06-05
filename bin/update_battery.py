#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys

# Exit safely if run on macOS (darwin) before trying to import dbus
if sys.platform == 'darwin':
    sys.exit("Warning: This script requires Linux D-Bus and UPower. It is not supported on macOS.")

import dbus
import time

def run_dbus_method(bus_type, obj, path, interface, method, arg):
    if bus_type == "session":
        bus = dbus.SessionBus()
    elif bus_type == "system":
        bus = dbus.SystemBus()
    else:
        return None

    proxy = bus.get_object(obj, path)
    dbus_method = proxy.get_dbus_method(method, interface)

    return dbus_method(arg) if arg else dbus_method()

def find_battery_path():
    call = [ 'system', 'org.freedesktop.UPower',
             '/org/freedesktop/UPower', 'org.freedesktop.UPower',
             'EnumerateDevices', None ]
    devices = run_dbus_method(*call)
    for i in devices:
        if 'BAT' in i:
            return str(i)

def main():
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 script.py <timeout_in_seconds>")

    bat_path = find_battery_path()
    if not bat_path:
        sys.exit("Error: No battery found via UPower.")

    call = [ 'system', 'org.freedesktop.UPower',
             bat_path, 'org.freedesktop.UPower.Device',
             'Refresh', None ]

    timeout = int(sys.argv[1])
    while True:
        run_dbus_method(*call)
        time.sleep(timeout)

if __name__ == '__main__':
    main()