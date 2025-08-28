#!/usr/bin/env bash

PACKAGES=(
  # Basic utils
  sudo
  wget
  curl
  jq
  apt-transport-https
  ca-certificates
  gnupg
  # Micro (text editor)
  micro
  xclip
  wl-clipboard
  # Gnome extra
  gnome-shell-extension-manager
  gnome-tweaks
  file-roller
  gnome-sushi
  # ddcutil, for monitor brightness
  ddcutil
  # Git and essential building tools
  git
  build-essential
  # clang (for clang-format at least)
  clang
  # Communication
  polari
  # Fonts
  fonts-firacode
  fonts-inconsolata
  fonts-roboto
  fonts-dejavu
  fonts-cantarell
  fonts-noto
  # Mail client (geary)
  geary
  # Photo/graphics utils
  inkscape
  gimp
  darktable
  # LaTeX
  texlive
  # Video utils
  mpv
  vlc
  # NFS
  nfs-common
  # Wireguard usermode tools
  wireguard-tools
  # QEMU
  qemu-system
  # Others
  pre-commit
  dbus-x11
)

EXTRA_PACKAGES=(
  discord
  fractal
  wasistlos
  revolt-desktop
  bitwarden
  spotify
  bw
  chromium
)

install_package_command() {
	apt-get install -y "${1}" >/dev/null 2>&1
}
install_extra_command() {
  snap install "${1}" >/dev/null 2>&1
}

refresh_package_db() {
  # Refresh apt db
  echo -e "Refreshing apt database..."
  apt-get update >/dev/null 2>&1
}

install_github_cli() {
  # GitHub CLI
  mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && mkdir -p -m 755 /etc/apt/sources.list.d \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt update \
  && apt install gh -y
}

install_docker() {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_kubectl() {
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
  chmod 644 /etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get install -y kubectl
}

install_ligconsolata() {
  curl -L -O https://github.com/googlefonts/Inconsolata/archive/refs/tags/v3.000.zip && unzip v3.000.zip \
  && cp Inconsolata-3.000/fonts/ttf/*.ttf "/usr/local/share/fonts/" && rm -rf Inconsolata-3.000 v3.000.zip
}

install_sops() {
  curl -LO https://github.com/getsops/sops/releases/download/v3.10.2/sops-v3.10.2.linux.amd64 && \
  mv sops-v3.10.2.linux.amd64 /usr/local/bin/sops && chmod +x /usr/local/bin/sops
}

export EXTRA_INSTALL_MESSAGE="Installing snap packages"
extra_init() {
  # Install ghostty
  ghostty=$(which ghostty >/dev/null 2>&1)
  if [ $? -ne 0 ]; then
    echo -ne "ghostty"
    # TODO: use a ppa / something updatable
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo -e "${BRed}Could not install ghostty. Skipping.${NC}"
    fi
    erase_text "ghostty"
  fi

  # Install 'ligconsolata' font
  install_ligconsolata >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "${BRed}Could not install Ligconsolata font. Skipping.${NC}"
  fi

  # Install VSCode
  # NOTE: would be better to install code-oss, and features+marketplace
  echo -ne "code"
  sudo snap install code --classic >/dev/null 2>&1
  erase_text "code"

  # TODO: Install jellyfin-media-player
  
  # Install android-studio
  echo -ne "android-studio"
  snap install android-studio --classic >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo ""
    echo -e "${BRed}Could not install android-studio. Skipping.${NC}"
  else
    erase_text "android-studio"
  fi
  
  # TODO: Install zen browser using official :) snap
  zen_browser=$(which zen-browser >/dev/null 2>&1)
  if [ $? -ne 0 ]; then
    echo -ne "zen-browser"
    curl -L -O https://git.vhaudiquet.fr/vhaudiquet/zen-browser-snap/releases/download/testing/zen-browser_1.14.11b_amd64.snap >/dev/null 2>&1
    snap install ./zen-browser_1.14.11b_amd64.snap --dangerous >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo ""
      echo -e "${BRed}Could not install zen-browser. Skipping.${NC}"
    else
      erase_text "zen-browser"
    fi
    rm -f ./zen-browser_1.14.11b_amd64.snap
  fi

  github_cli=$(which gh >/dev/null 2>&1)
  if [ $? -ne 0 ]; then
    echo -ne "github-cli"
    install_github_cli >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo ""
      echo -e "${BRed}Could not install github-cli. Skipping.${NC}"
    else
      erase_text "github-cli"
    fi
  fi

  # Docker, Kubectl
  docker=$(which docker >/dev/null 2>&1)
  if [ $? -ne 0 ]; then
    echo -ne "docker"
    install_docker >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo ""
      echo -e "${BRed}Could not install docker. Skipping.${NC}"
    else
      erase_text "docker"
    fi
  fi

  kubectl=$(which kubectl >/dev/null 2>&1)
  if [ $? -ne 0 ]; then 
    echo -ne "kubectl"
    install_kubectl >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo ""
      echo -e "${BRed}Could not install kubectl. Skipping.${NC}"
    else
      erase_text "kubectl"
    fi
  fi

  # SOPS
  sops=$(which sops >/dev/null 2>&1)
  if [ $? -ne 0 ]; then
    echo -ne "sops"
    install_sops >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo ""
      echo -e "${BRed}Could not install sops. Skipping.${NC}"
    else
      erase_text "sops"
    fi
  fi
}

disable_unwanted_extensions() {
    # Disable default Ubuntu gnome extensions
    sudo -u ${USERNAME} gnome-extensions disable ding@rastersoft.com # Desktop Icons
}

extra_finish() {
  disable_unwanted_extensions
}
