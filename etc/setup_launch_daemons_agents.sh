# shellcheck disable=SC2016

for plist_file in "${1}"/*.plist; do
    chown_plist_cmd='chown ${USER}:$(id --group --name "${USER}") '"${plist_file}"
    ln_plist_cmd="ln -sfv ${plist_file} $2/$(basename "${plist_file}")"
    unload_plist_cmd="launchctl unload -w $2/$(basename "${plist_file}")"
    load_plist_cmd="launchctl load -w $2/$(basename "${plist_file}")"
    plist_cmd="${chown_plist_cmd}; ${ln_plist_cmd}; ${unload_plist_cmd}; ${load_plist_cmd}"

    if [[ -n "$(find "$2" -maxdepth 0 -user root)" ]]; then
        sudo -- bash -c "${plist_cmd}"
    else
        bash -c "${plist_cmd}"
    fi
done
