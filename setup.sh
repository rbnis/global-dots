#!/bin/bash

install_dependencies() {
  # Supported packetmanagers are apt and brew (on mac)
  dependencies_linux_apt=("curl" "httpie" "tldr" "neovim" "xclip")
  dependencies_linux_pacman=("curl" "httpie" "tldr" "nvim" "xclip")
  dependencies_darvin_brew=("coreutils" "gnu-sed" "httpie" "iterm2" "kubectl" "kubectx" "secretive" "tealdear" "nvim")

  if [ ! -f "$(which zsh)" ]; then
    while true; do
      read -rp "Also install zsh? [y/n]: " yn < /dev/tty
      case $yn in
        [Yy]*) dependencies_linux_apt+=("zsh") && dependencies_darvin_brew+=("zsh") && break ;;
        [Nn]*) break ;;
      esac
    done
  fi

  if [ "$(uname)" == "Linux" ]; then
    # Linux
    if [ -f /etc/os-release ]; then
      # shellcheck disable=SC1091
      . /etc/os-release

      if [ "$ID" == 'ubuntu' ] || [ "$ID" == 'debian' ] ; then
        sudo apt-get -y install "${dependencies_linux_apt[@]}"
      elif [ "$ID" == 'arch' ] ; then
        # sudo pacman -S
        sudo pacman -S "${dependencies_linux_pacman[@]}"
        echo noop
      fi
    fi
  elif [ "$(uname)" == "Darwin" ]; then
    # MacOS
    if [ ! -f "$(which brew)" ]; then
      # Brew needs to be installed first
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    for package in "${dependencies_darvin_brew[@]}"
    do
      brew install "$package"
    done
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    while true; do
      read -rp "Install oh-my-zsh? [y/n]: " yn < /dev/tty
      case $yn in
        [Yy]*) /bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && break ;;
        [Nn]*) break ;;
      esac
    done
  fi

  if [ ! "$SHELL" == "$(which zsh)" ]; then
    while true; do
      read -rp "Change default shell to zsh? [y/n]: " yn < /dev/tty
      case $yn in
        [Yy]*) chsh -s "$(which zsh)" && break ;;
        [Nn]*) break ;;
      esac
    done
  fi
}

link_config_files() {
  sourcedir=$(dirname "$(realpath "$0")")

  # Iterate over all files, except this setup itself.
  find . \
    -not -path './setup.sh' -and \
    -not -path './README.md' -and \
    -not -path './.editorconfig' -and \
    -not -path './*.gitignore' -and \
    -not -path './.git/*' -and \
    -not -path './*.DS_Store' \
    -not -type d -print0 | while read -rd $'\0' file
  do
    # Check if the target file ist already present.
    if [ ! -f "$HOME/${file:2}" ]; then
      if [ ! -d "$(dirname "$HOME"/"${file:2}")" ]; then
        mkdir -p "$(dirname "$HOME"/"${file:2}")"
      fi

      # If the target is not present just create the symlink.
      ln -s "$sourcedir/${file:2}" "$HOME/${file:2}"
    else
      # Otherwise let the user decide what to do
      if [ -L "$HOME/${file:2}" ]; then
        # If it's a symlink, first check if it's targeted at the correct file
        if [ "$(readlink "$HOME"/"${file:2}")" = "$sourcedir/${file:2}" ]; then
          # If so, do nothing
          continue
        fi
        echo "Target \"$HOME/${file:2}\" already exists."
        echo "Symlink pointing at \"$(readlink "$HOME"/"${file:2}")\" instead of \"$sourcedir/${file:2}\"."
      else
        echo "Target \"$HOME/${file:2}\" already exists."
        echo "File instead if symlink."
      fi

      # If the target exists, let the user decide to overwrite it
      while true; do
        read -rp "Overwrite or backup [b] target? [y/n/b]: " ynb < /dev/tty
        case $ynb in
          [Yy]*) rm "$HOME/${file:2}" && ln -s "$sourcedir/${file:2}" "$HOME/${file:2}" && break ;;
          [Nn]*) break ;;
          [Bb]*) mv "$HOME/${file:2}" "$HOME/${file:2}.bkp" && ln -s "$sourcedir/${file:2}" "$HOME/${file:2}" && break ;;
        esac
      done
    fi
  done

  # Link zsh themes
  find "$HOME/.config/zsh/themes" \
    -name '*.zsh-theme' \
    -not -path './*.DS_Store' \
    -not -type d -print0 | while read -rd $'\0' file
  do
    if [ -d "$HOME/.oh-my-zsh" ]; then
      if [ ! -d "$HOME/.oh-my-zsh/custom/themes" ]; then
        mkdir -p "$HOME/.oh-my-zsh/custom/themes"
      fi

      ln -sf "$file" "$HOME/.oh-my-zsh/custom/themes/$(basename "$file")"
    fi
  done
}

source_shell_config() {
  if [ -f "$HOME/.bashrc" ]; then
    find . \( -path './.config/shell/*' -or -path './.config/bash/*' \) -and -not -type d -print0 | while read -rd $'\0' file
    do
      if ! grep -q "source \"\$HOME/${file:2}\"" "$HOME/.bashrc"; then
        echo "source \"\$HOME/${file:2}\"" >> "$HOME/.bashrc"
      fi
    done
  fi
}

if [ ! "$1" == "--skip-install" ]; then
  install_dependencies
fi
link_config_files
source_shell_config
