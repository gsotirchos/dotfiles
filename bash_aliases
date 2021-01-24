# rm wrapper to move file(s) to trash folder
trash() {
    flags=""
    for arg in "$@"; do
        if [[ ${arg} == -* ]]; then
            flags="${flags} ${arg}"
            continue
        fi

        # move file to trash folder, or delete /tmp/* files
        if [[ ${arg} == "/tmp/"* ]]; then
            #echo "rm ${flags} ${arg}"
            rm ${flags} "${arg}"
        else
            #echo "mv -v ${flags} ${arg} ${TRASH}"
            mv -v ${flags} "${arg}" "${TRASH}"
        fi
    done
}

# aliases
alias rm="trash"  # trash file instead of deleting
#alias rm="rm -i"  # confirmatory remove
alias mv="mv -iv" # confirmatory, verbose move
alias cp="cp -iv" # confirmatory, verbose copy
alias ln="ln -iv" # confirmatory, verbose symlink creaton
alias tree="tree -NC -L 2 --filelimit 15" # cleaner tree
alias dunnet="clear && emacs -batch -l dunnet"
alias pkg_list="pkg_info -u | sed 's/\(.*\)-[0-9].*/\1/g'"
