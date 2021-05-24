#!/usr/bin/env bash

#
# ${DOTFILES}/setup.sh
#

# styling
BR_TEXT='\033[0;97m'
DEF_TEXT='\033[0m'

# check for `realpath` command
if ! command -v realpath &> /dev/null; then
    echo -e "${BR_TEXT}Error: \`realpath\` command could not be found. Aborted${DEF_TEXT}"
    exit
fi

# dotfiles path
DOTFILES=$(\
    builtin cd "$(\
        dirname "$(realpath ${BASH_SOURCE[0]})"\
    )" > /dev/null && pwd)

# prepare folders
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/spell
mkdir -vp ~/.vim/words
mkdir -vp ~/.local/bin
touch ~/.hushlogin

# make soft symlinks
echo -e "${BR_TEXT}- Symlinking dotfiles (${DOTFILES})${DEF_TEXT}"
"${DOTFILES}"/bin/ln_dotfiles "${DOTFILES}" "${HOME}/."  # dotfiles root
ln -sfv "${DOTFILES}"/vim/* ~/.vim  # vim

# setup launch daemons
for plist_file in "${HOME}/.dotfiles/LaunchDaemons/"*.plist; do
    sudo ln -sfv "${plist_file}"\
        "/Library/LaunchDaemons/$(basename ${plist_file})"
    sudo chown root:wheel\
        "/Library/LaunchDaemons/$(basename ${plist_file})"
    sudo launchctl load -w\
        "/Library/LaunchDaemons/$(basename ${plist_file})"
done

# setup vundle
if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
    echo -e "${BR_TEXT}- Couldn't locate ~/.vim/bundle/Vundle.vim, setting up...${DEF_TEXT}"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
fi

# setup julia
if command -v "julia" &> /dev/null; then
    echo -e "${BR_TEXT}\n- Setting up Julia${DEF_TEXT}"
    "${DOTFILES}"/julia/setup-julia.sh
fi
