# vim: set ft=bash:

# rm wrapper to move file(s) to trash folder
trash() {
    flags=""
    for arg in $@; do
        if [[ ${arg} == -* ]]; then
            flags="${flags} ${arg}"
            continue
        fi

        # move file to trash folder, or delete /tmp/* files
        if [[ ${arg} == "/tmp/"* ]]; then
            #echo "rm -r ${arg}"
            env rm -r "${arg%/}"
        else
            #echo "mv ${flags} -v --backup=numbered ${arg%/} ${TRASH}"
            env mv ${flags} -v --backup=numbered "${arg%/}" "${TRASH}"
        fi
    done
}

# function to empty trash
empty_trash() {
    read -p "Are you sure you want to permamently erase the items in the trash? [y/N] " -r
    if [[ ${REPLY} =~ ^[Yy]$ ]]; then
        for file in "${TRASH}"/{..?,.[!.],}*; do
            if ([[ -e "${file}" ]] || [[ -L "${file}" ]]); then
                env rm -rf "${file}" && \
                    echo "deleted '${file}'"
            fi
        done
    fi
}

# aliases
alias rm=trash  # trash files instead of deleting
alias mv="mv -iv"  # confirmatory, verbose move
alias cp="cp -iv"  # confirmatory, verbose copy
alias ln="ln -iv"  # confirmatory, verbose symlink creaton
alias ls="ls -h --color=always"  # human-readable, colored ls
alias grep="grep --color -E"  # use colors & enable extended regexp
alias tree="tree -lNFC -L 2 \
    --dirsfirst \
    -I '.DS_Store|.localized|._*' --matchdirs"  # cleaner tree
alias sftp="with-readline sftp"
alias dunnet="clear && emacs -batch -l dunnet"
alias pkg_list="pkg_info -u | sed 's/\(.*\)-[0-9].*/\1/g'"
alias vimrc="vim ~/.vim/vimrc"
alias py="python3"
alias pip-upgrade='conda upgrade --all && conda list | grep "pypi" | cut -d " " -f 1 | xargs pip install --upgrade'
alias drl="conda activate drl"
alias wssetup="cd ~/Coding/ROS/learning_catkin_ws/ && . devel/setup.bash"

if [[ -d "${HOME}/Applications/PlayOnMac/Guild Wars 2.app" ]]; then
    alias guildwars2="${HOME}/Applications/PlayOnMac/Guild\ Wars\ 2.app/Contents/MacOS/playonmac"
fi

if [[ -d "/Applications/PlayOnMac.app" ]]; then
    alias playonmac='/Applications/PlayOnMac.app/Contents/MacOS/playonmac'
fi
