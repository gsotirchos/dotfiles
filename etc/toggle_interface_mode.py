#!/usr/bin/env python3

import subprocess
from datetime import datetime


OSASCRIPT = """
    tell application "System Events"
        tell appearance preferences
            set dark mode to {mode}
        end tell
    end tell

    tell application "Terminal"
        set default settings to settings set "{theme}"
    end tell

    tell application "Terminal"
        set current settings of tabs of windows to settings set "{theme}"
    end tell
"""

TERMINAL_THEMES = {
    "Light": "Yorha",
    "Dark": "Dracula"}

IS_DARK_MODE = {
    "Dark": "true",
    "Light": "false"}

TIME_FORMAT = "%H:%M"

ON_TIME = datetime.strptime(
    "20:00",
    TIME_FORMAT)
OFF_TIME = datetime.strptime(
    "07:30",
    TIME_FORMAT)

def current_mode() -> str:
    """ return the current Dark Mode status """
    result = subprocess.run(
        ["defaults", "read", "-g", "AppleInterfaceStyle"],
        text=True,
        capture_output=True)

    if result.returncode == 0 \
            and result.stdout.strip() == "Dark":
        return "Dark"
    else:
        return "Light"

def mode() -> str:
    """ get current time """
    time_query = subprocess.run(
        ["date", "+%H:%M"],
        text = True,
        capture_output = True)

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

def set_interface_style(mode: str, current_mode: str):
    """ enable/disable dark mode """
    if current_mode != mode:
        script = OSASCRIPT.format(
            mode = IS_DARK_MODE[mode],
            theme = TERMINAL_THEMES[mode])

        result = subprocess.run(
            ['osascript', '-e', script],
            text = True,
            capture_output = True)
        assert result.returncode == 0, result


if __name__ == "__main__":
    set_interface_style(mode(), current_mode())
