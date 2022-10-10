#!/usr/bin/env python3

import subprocess
from datetime import datetime

SET_INTERFACE_OSASCRIPT = """
    tell application "System Events"
        tell appearance preferences
            set dark mode to {mode}
        end tell
    end tell"""

SET_TERMINAL_OSASCRIPT = """
    tell application "Terminal"
        set default settings to settings set "{theme}"
    end tell

    tell application "Terminal"
        set current settings of tabs of windows to settings set "{theme}"
    end tell"""

CHECK_TERMINAL_OSASCRIPT = """
    if application "Terminal" is running then return true"""

TERMINAL_THEMES = {
    "Light": "Shoji",
    "Dark": "Xcode"}

IS_DARK_MODE = {
    "Dark": "true",
    "Light": "false"}

TIME_FORMAT = "%H:%M"

ON_TIME = datetime.strptime(
    "19:00",
    TIME_FORMAT)
OFF_TIME = datetime.strptime(
    "07:30",
    TIME_FORMAT)


# return 'true' if terminal is currently running
def terminal_is_running() -> bool:
    result = subprocess.run(
        ['osascript', '-e', CHECK_TERMINAL_OSASCRIPT],
        text=True,
        capture_output=True)
    if result.returncode == 0 and result.stdout.strip() == "true":
        return True
    else:
        return False


# return the current interface mode
def current_interface_mode() -> str:
    result = subprocess.run(
        ["defaults", "read", "-g", "AppleInterfaceStyle"],
        text=True,
        capture_output=True)

    if result.returncode == 0 and result.stdout.strip() == "Dark":
        return "Dark"
    else:
        return "Light"


# return the current Terminal mode
def current_terminal_mode() -> str:
    result = subprocess.run(
        ["defaults", "read", "com.Apple.Terminal",
            "Default Window Settings"],
        text=True,
        capture_output=True)

    if result.stdout.strip() == TERMINAL_THEMES["Dark"]:
        return "Dark"
    else:
        return "Light"


# return the desired mode
def desired_mode() -> str:
    """ get current time """
    time_query = subprocess.run(
        ["date", "+%H:%M"],
        text=True,
        capture_output=True)

    if time_query.returncode != 0:
        raise OSError('Could not get time.')
    else:
        time = datetime.strptime(
            time_query.stdout.strip(),
            TIME_FORMAT)

    """ return desired mode """
    if time < OFF_TIME or time > ON_TIME:
        return "Dark"
    else:
        return "Light"


# enable/disable dark mode interface
def set_interface_style():
    the_desired_mode = desired_mode()
    if current_interface_mode() is not desired_mode:
        script = SET_INTERFACE_OSASCRIPT.format(
            mode=IS_DARK_MODE[the_desired_mode])

        result = subprocess.run(
            ['osascript', '-e', script],
            text=True,
            capture_output=True)
        assert result.returncode == 0, result


# enable/disable dark mode Terminal
def set_terminal_style():
    if not terminal_is_running():
        return

    the_terminal_mode = current_terminal_mode()
    the_interface_mode = current_interface_mode()
    if the_interface_mode == "Dark":
        the_desired_mode = "Dark"
    else:
        the_desired_mode = desired_mode()

    if the_terminal_mode is not desired_mode:
        script = SET_TERMINAL_OSASCRIPT.format(
            theme=TERMINAL_THEMES[the_desired_mode])

        result = subprocess.run(
            ['osascript', '-e', script],
            text=True,
            capture_output=True)
        assert result.returncode == 0, result


if __name__ == "__main__":
    # set_interface_style()
    set_terminal_style()
