#!/usr/bin/env bash

set -e

DOTFILES_DIR=$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)

entry_point="$0"

COLOR_RESET=$(tput sgr0)
COLOR_RED=$(tput setaf 124)
COLOR_BOLD=$(tput bold)

ERR() {
  echo -e [${COLOR_BOLD}${COLOR_RED}ERROR${COLOR_RESET}] "$@" >&2
  exit 2
}

INFO() {
  echo -e [${COLOR_BOLD}INFO${COLOR_RESET}] "$@"
}

WARN() {
  echo -e [${COLOR_BOLD}${COLOR_RED}WARNING${COLOR_RESET}] "$@" >&2
}

mkdir_and_check() {
  local d="$1"

  if [ ! -d "$d" ]; then
    mkdir -p "$d"
    if [ ! -d "$d" ]; then
      ERR "$d should be a folder"
    fi
    echo "$d created"
  fi
}

yes_or_no_question() {
  # assign local variable from function in linux bash a new value
  # https://stackoverflow.com/questions/22527325/assign-local-variable-from-function-in-linux-bash-a-new-value
  local question="$1"
  local default=n
  local hint="[y/N]"

  if [[ "$(echo $2 | tr '[:upper:]' '[:lower:]')" == y* ]]; then
    default=y
    hint="[Y/n]"
  fi

  echo -en [${COLOR_BOLD}Q${COLOR_RESET}] "$question $hint "
  local input
  read input
  if [ -z "$input" ]; then
    input="$default"
  fi
  if [[ "$(echo $input | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
    return 0
  else
    return 1
  fi
}

install_target() {
  local src="$1"
  local dest="$2"

  local category="${src%%/*}"
  local stripped_src="${src#$category/}"

  case "$category" in
    home)
      local prefix="${HOME}/"
      ;;
    root)
      local prefix="/"
      ;;
    *)
      WARN "target $src is not supported"
      return 1
      ;;
  esac

  if [ -z "$dest" ]; then
    dest="${prefix}${stripped_src}"
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    if [ -e "${dest}.bak" ]; then
      ERR "backup of $dest is already exists"
    fi
    mv "$dest" "${dest}.bak"
    echo "$dest was backed up"
  fi

  ln -s "${DOTFILES_DIR}/${src}" "$dest"
  echo "$dest was installed"
}

install() {
  local bg=dark
  if yes_or_no_question "Is your terimnal background \"light\"?"; then
    bg=light
  fi

  mkdir_and_check "${HOME}/bin.d"
  mkdir_and_check "${HOME}/.config/dircolors"
  mkdir_and_check "${HOME}/.config/fish/conf.d"
  mkdir_and_check "${HOME}/.config/wezterm"

  case "$(echo $OSTYPE | tr '[:upper:]' '[:lower:]')" in
    cygwin*|msys*)
      mkdir_and_check "${HOME}/AppData/Local/nvim"
      mkdir_and_check "${HOME}/AppData/Local/nvim/after/ftplugin"
      mkdir_and_check "${HOME}/AppData/Local/nvim/lua"
      mkdir_and_check "${HOME}/AppData/Local/nvim/lua/plugins"
      ;;
    darwin*)
      mkdir_and_check "${HOME}/Library/Fonts"
      mkdir_and_check "${HOME}/.config/nvim"
      mkdir_and_check "${HOME}/.config/nvim/after/ftplugin"
      mkdir_and_check "${HOME}/.config/nvim/lua"
      mkdir_and_check "${HOME}/.config/nvim/lua/plugins"
      ;;
    linux*)
      mkdir_and_check "${HOME}/.local/share/fonts"
      mkdir_and_check "${HOME}/.config/fontconfig/conf.d"
      mkdir_and_check "${HOME}/.config/nvim"
      mkdir_and_check "${HOME}/.config/nvim/after/ftplugin"
      mkdir_and_check "${HOME}/.config/nvim/lua"
      mkdir_and_check "${HOME}/.config/nvim/lua/plugins"
      ;;
  esac

  install_target "home/bin.d/johannjhang"

  install_target "home/.zshenv"
  install_target "home/.zshrc"
  if [ "$bg" = "light" ]; then
    install_target "home/.zshrc.light"
  fi

  install_target "home/.config/fish/conf.d/johannjhang.fish"

  if [ "$bg" = "light" ]; then
    install_target "home/.config/dircolors/dircolors.light" "${HOME}/.config/dircolors/dircolors"
  else
    install_target "home/.config/dircolors/dircolors"
  fi

  install_target "home/.tmux"
  install_target "home/.tmux.conf"
  if [ "$bg" = "light" ]; then
    install_target "home/.tmux.light.conf"
  fi
  case "$(echo $OSTYPE | tr '[:upper:]' '[:lower:]')" in
    cygwin*|msys*)
      install_target "home/.tmux.windows.conf"
      ;;
    darwin*)
      install_target "home/.tmux.darwin.conf"
      ;;
  esac

  install_target "home/.ideavimrc"

  if yes_or_no_question "Nerd Font supported?" y; then
    install_target "home/.p10k.zsh"
  else
    install_target "home/.p10k-no-nerd-font.zsh" "${HOME}/.p10k.zsh"
  fi

  install_target "home/.wezterm.lua"
  install_target "home/.config/wezterm/color_scheme"
  install_target "home/.config/wezterm/font"
  install_target "home/.config/wezterm/font_size"

  case "$(echo $OSTYPE | tr '[:upper:]' '[:lower:]')" in
    cygwin*|msys*)
      install_target "home/AppData/Local/nvim/init.lua"
      install_target "home/AppData/Local/nvim/lua/init-lazy.lua"
      install_target "home/AppData/Local/nvim/lua/plugins/default.lua"
      if [ "$bg" = "light" ]; then
        install_target "home/AppData/Local/nvim/lua/init-light.lua"
      fi
      install_target "home/AppData/Local/nvim/after/ftplugin/c.lua"
      install_target "home/AppData/Local/nvim/after/ftplugin/cmake.lua"
      install_target "home/AppData/Local/nvim/after/ftplugin/cpp.lua"
      install_target "home/AppData/Local/nvim/after/ftplugin/gitcommit.lua"
      install_target "home/AppData/Local/nvim/after/ftplugin/markdown.lua"
      install_target "home/AppData/Local/nvim/after/ftplugin/python.lua"
      ;;
    *)
      install_target "home/.config/nvim/init.lua"
      install_target "home/.config/nvim/lua/init-lazy.lua"
      install_target "home/.config/nvim/lua/plugins/default.lua"
      if [ "$bg" = "light" ]; then
        install_target "home/.config/nvim/lua/init-light.lua"
      fi
      install_target "home/.config/nvim/after/ftplugin/c.lua"
      install_target "home/.config/nvim/after/ftplugin/cmake.lua"
      install_target "home/.config/nvim/after/ftplugin/cpp.lua"
      install_target "home/.config/nvim/after/ftplugin/gitcommit.lua"
      install_target "home/.config/nvim/after/ftplugin/markdown.lua"
      install_target "home/.config/nvim/after/ftplugin/python.lua"
      ;;
  esac

  # TODO: Highlight modifications will be done on existing config

  if yes_or_no_question "Set Neovim as the default Git editor" y; then
    git config --global core.editor nvim
    git config --global diff.tool nvimdiff
    git config --global difftool.nvimdiff.layout "LOCAL, REMOTE"
    git config --global merge.tool nvimdiff
    git config --global mergetool.nvimdiff.layout "(LOCAL, BASE, REMOTE) / MERGED"
  fi

  if yes_or_no_question "Set Visual Studio Code as the default Git editor"; then
    git config --global core.editor vscode
    git config --global diff.tool vscode
    git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
    git config --global merge.tool vscode
    git config --global mergetool.vscode.cmd 'code --wait --merge $BASE $LOCAL $REMOTE $MERGED'
  fi

  INFO "Listing Git config that will be installed below:"
  cat << EOF
alias.show-tracked-ignored = "ls-files -i --exclude-standard"
core.quotePath = false
core.autocrlf = false
core.safecrlf = warn
color.ui = auto
diff.algorithm = patience
difftool.prompt = false
mergetool.prompt = true
pull.ff = only
push.default = simple
EOF
  if yes_or_no_question "Install the above Git config? (Cannot be undone)" y; then
    git config --global alias.show-tracked-ignored "ls-files -i --exclude-standard"
    git config --global core.quotePath false
    git config --global core.autocrlf false
    git config --global core.safecrlf warn
    git config --global color.ui auto
    git config --global diff.algorithm patience
    git config --global difftool.prompt false
    git config --global mergetool.prompt true
    git config --global pull.ff only
    git config --global push.default simple
    echo "Git config was installed"
  fi

  case "$(echo $OSTYPE | tr '[:upper:]' '[:lower:]')" in
    linux*)
      install_target "home/.config/fontconfig/conf.d/20-noto-cjk.conf"
      fc-cache -fv
      ;;
  esac

  INFO "Installation has been completed"
}

uninstall_target() {
  local f="$1"

  if [[ ! -e "$f" && ! -L "$f" ]]; then
    return
  fi

  local readlink=readlink
  case "$(echo $OSTYPE | tr '[:upper:]' '[:lower:]')" in
    darwin*)
      readlink=greadlink
      ;;
  esac

  if [ ! -L "$f" ] || [[ "$($readlink -f "$f")" != "${DOTFILES_DIR}/"* ]]; then
    WARN "$f skipped"
    return
  fi

  unlink "$f"
  echo "$f was uninstalled"

  if [ -e "${f}.bak" ]; then
    mv "${f}.bak" "$f"
    echo "backup of ${f} was restored"
  fi
}

uninstall() {
  uninstall_target "${HOME}/bin.d/johannjhang"

  uninstall_target "${HOME}/.p10k.zsh"
  uninstall_target "${HOME}/.zshenv"
  uninstall_target "${HOME}/.zshrc"
  uninstall_target "${HOME}/.zshrc.light"

  uninstall_target "${HOME}/.config/fish/conf.d/johannjhang.fish"

  uninstall_target "${HOME}/.wezterm.lua"
  uninstall_target "${HOME}/.config/wezterm/color_scheme"
  uninstall_target "${HOME}/.config/wezterm/font"
  uninstall_target "${HOME}/.config/wezterm/font_size"

  uninstall_target "${HOME}/.config/dircolors/dircolors"

  uninstall_target "${HOME}/.tmux"
  uninstall_target "${HOME}/.tmux.conf"
  uninstall_target "${HOME}/.tmux.darwin.conf"
  uninstall_target "${HOME}/.tmux.windows.conf"
  uninstall_target "${HOME}/.tmux.light.conf"

  uninstall_target "${HOME}/.ideavimrc"

  uninstall_target "${HOME}/.config/fontconfig/conf.d/20-noto-cjk.conf"

  uninstall_target "${HOME}/.config/nvim/init.lua"
  uninstall_target "${HOME}/.config/nvim/lua/init-lazy.lua"
  uninstall_target "${HOME}/.config/nvim/lua/plugins/default.lua"
  uninstall_target "${HOME}/.config/nvim/after/ftplugin/c.lua"
  uninstall_target "${HOME}/.config/nvim/after/ftplugin/cmake.lua"
  uninstall_target "${HOME}/.config/nvim/after/ftplugin/cpp.lua"
  uninstall_target "${HOME}/.config/nvim/after/ftplugin/gitcommit.lua"
  uninstall_target "${HOME}/.config/nvim/after/ftplugin/markdown.lua"
  uninstall_target "${HOME}/.config/nvim/after/ftplugin/python.lua"
  uninstall_target "${HOME}/.config/nvim/lua/init-light.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/init.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/lua/init-lazy.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/lua/plugins/default.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/after/ftplugin/c.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/after/ftplugin/cmake.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/after/ftplugin/cpp.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/after/ftplugin/gitcommit.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/after/ftplugin/markdown.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/after/ftplugin/python.lua"
  uninstall_target "${HOME}/Appdata/Local/nvim/lua/init-light.lua"

  INFO "Uninstallation has been completed"
}

case "$(echo $OSTYPE | tr '[:upper:]' '[:lower:]')" in
  cygwin*|msys*)
    # Enable the symbolic link support on Windows
    export MSYS=winsymlinks:nativestrict
    ;;
esac

if [[ "$entry_point" == *bash ]]; then
  ERR "File was sourced but not executed"
fi

cd "$DOTFILES_DIR"

if [[ $(basename "$BASH_SOURCE") == "install"* ]]; then
  if yes_or_no_question "Continue to uninstall old dotfiles?" y; then
    uninstall
  fi
  if yes_or_no_question "Continue to install?" y; then
    install
  fi
elif [[ $(basename "$BASH_SOURCE") == "uninstall"* ]]; then
  if yes_or_no_question "Continue to uninstall?" y; then
    uninstall
  fi
fi
