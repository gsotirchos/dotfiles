#!/usr/bin/env bash
# SessionStart hook: prints the ROS / dev container rules that apply to the session's directory.
context_dir="$(dirname "$(realpath "$0")")/../context"
dir="$(realpath "${CLAUDE_PROJECT_DIR:-$PWD}")"
ros=false
devcontainer=false
pixi=false

while :; do
  compgen -G "$dir/package.xml" >/dev/null ||
    compgen -G "$dir/colcon_defaults.yaml" >/dev/null ||
    compgen -G "$dir/src/*/package.xml" >/dev/null ||
    compgen -G "$dir/src/*/*/package.xml" >/dev/null && ros=true
  compgen -G "$dir/.devcontainer" >/dev/null ||
    compgen -G "$dir/src/*/.devcontainer" >/dev/null && devcontainer=true
  [ -e "$dir/pixi.toml" ] && pixi=true
  [ "$dir" = / ] && break
  dir="$(dirname "$dir")"
done

"$ros" && cat "$context_dir/ros.md"
"$devcontainer" && ! "$pixi" && cat "$context_dir/devcontainer.md"
exit 0
