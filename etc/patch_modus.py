#!/usr/bin/env python3
import os
import re

# Paths relative to the script's location (${dotfiles}/etc/patch_modus.py)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DOTFILES_DIR = os.path.dirname(SCRIPT_DIR)
THEMES_DIR = os.path.join(DOTFILES_DIR, "config/ghostty/ghostty-themes/themes")
OUTPUT_DIR = os.path.join(DOTFILES_DIR, "config/ghostty/themes")

def get_brightness(hex_color):
    hex_color = hex_color.lstrip('#')
    if len(hex_color) == 3:
        hex_color = ''.join([c*2 for c in hex_color])
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    # Perceptive brightness
    return (r * 0.299 + g * 0.587 + b * 0.114)

def patch_theme(theme_name):
    input_path = os.path.join(THEMES_DIR, theme_name)
    output_path = os.path.join(OUTPUT_DIR, f"patched-{theme_name}")

    if not os.path.exists(input_path):
        return

    with open(input_path, 'r') as f:
        content = f.read()

    # Extract palette colors 0, 7, 8, 15
    palette = {}
    for match in re.finditer(r'palette\s*=\s*(\d+)\s*=\s*(#[0-9a-fA-F]+|[a-zA-Z]+)', content):
        idx = int(match.group(1))
        if idx in [0, 7, 8, 15]:
            palette[idx] = match.group(2)

    if 7 not in palette:
        return

    # In Ghostty Modus themes:
    # Light theme: Color 7 is dark (Black)
    # Dark theme: Color 7 is light (White)
    is_dark_theme = get_brightness(palette[7]) > 128

    overrides = {}
    if is_dark_theme:
        # Dark mapping: 7 <-> 15
        overrides[7] = palette[15]
        overrides[15] = palette[7]
    else:
        # Light mapping: 0 -> 15, 7 -> 0, 8 -> 7, 15 -> 8
        overrides[0] = palette[7]
        overrides[7] = palette[8]
        overrides[8] = palette[15]
        overrides[15] = palette[0]

    # Apply overrides
    new_content = content
    for idx, color in overrides.items():
        # Replace the specific palette line for this index
        pattern = rf'(palette\s*=\s*{idx}\s*=\s*)(?:#[0-9a-fA-F]+|[a-zA-Z]+)'
        new_content = re.sub(pattern, rf'\1{color}', new_content)

    with open(output_path, 'w') as f:
        f.write(f"# Patched version of {theme_name}\n")
        f.write(new_content)

def main():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    for filename in os.listdir(THEMES_DIR):
        if filename.startswith("modus-"):
            patch_theme(filename)

if __name__ == "__main__":
    main()
