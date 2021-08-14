#!/usr/bin/env bash

# vim: set ft=bash:

# determine OS
if [[ "$(uname -s)" == *"Linux"* ]]; then
    f_perm="775"
    d_perm="664"
else
    f_perm="755"
    d_perm="644"
fi

ssh_perm="700"

echo "Fixing owner"
sudo chown -R "${USER}:${USER}" "${HOME}"
echo "Fixing directory permissions"
find "${HOME}" -type d -print0 | xargs -0 chmod -R "${d_perm}"
echo "Fixing file permissions"
find "${HOME}" -type f -print0 | xargs -0 chmod "${f_perm}"
echo "Fixing ~/.ssh permissions"
chmod -R "${ssh_perm}" "${HOME}/.ssh"
