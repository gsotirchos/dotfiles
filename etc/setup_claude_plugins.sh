#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $(basename "$0") <settings_file> <target_dir>" >&2
    exit 1
fi

settings_file="$1"
target_dir="$2"
mapfile -t repos < <(
    jq -r '.extraKnownMarketplaces.gsotirchos.source.plugins[].source.repo' \
        "${settings_file}"
)

mkdir -p "${target_dir}"
for repo in "${repos[@]}"; do
    clone_dir="${target_dir}/${repo#*/}"
    [[ -d "${clone_dir}" ]] && continue
    git clone "https://github.com/${repo}.git" "${clone_dir}" \
        || echo "Warning: could not clone ${repo}; rerun once it is reachable" >&2
done
