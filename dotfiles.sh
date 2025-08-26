#!/usr/bin/env bash

install_dotfile_ifnot() {
    mkdir -p $(dirname -- /home/${USERNAME}/${1})
    cp --update=none ${script_dir}/dotfiles/${1} /home/${USERNAME}/${1}
}

echo "Installing dotfiles..."
# cp -r --update=none ${script_dir}/dotfiles/. /home/${USERNAME}/
cat ${script_dir}/dotfiles/.config/git/config | envsubst '$GIT_USER $EMAIL' >/home/${USERNAME}/.config/git/config

# Install bashrc if not mymachine-installed
if ! [[ "$(head -n 1 /home/${USERNAME}/.bashrc)" = "# mymachine" ]]; then
    cp "${script_dir}/dotfiles/.bashrc" "/home/${USERNAME}/.bashrc"
fi

# Install code settings depending on which code is installed
CODE_NAME="Code - OSS"
if [ "${ID}" = "ubuntu" ]; then
    # On Ubuntu, we install official code snap
    CODE_NAME="Code"
fi
mkdir -p /home/${USERNAME}/.config/${CODE_NAME}/User
cp "${script_dir}/dotfiles/.config/Code - OSS/User/settings.json" "/home/${USERNAME}/.config/${CODE_NAME}/User/settings.json"

# Install ghostty, git, gh settings if not present
install_dotfile_ifnot .config/ghostty/config
install_dotfile_ifnot .config/git/config
install_dotfile_ifnot .config/gh/config.yml
