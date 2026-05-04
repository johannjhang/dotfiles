# General {
## Redefine ctrl-d to delete the character under the cursor
bind \cd delete-char

## locale
if not set --query LANG
    set --export LANG en_US.UTF-8
end
if not set --query LC_ALL
    set --export LC_ALL en_US.UTF-8
end

## system bin
## Mainly to solve the PATH issue in MSYS2
if test -d /bin; and not contains /bin $PATH
    fish_add_path /bin
end
if test -d /usr/bin; and not contains /usr/bin $PATH
    fish_add_path /usr/bin
end
if test -d /usr/sbin; and not contains /usr/sbin $PATH
    fish_add_path /usr/sbin
end
if test -d /usr/local/bin; and not contains /usr/local/bin $PATH
    fish_add_path /usr/local/bin
end

## bin
fish_add_path $HOME/bin
if test -d $HOME/bin.d
    for d in $HOME/bin.d/*
        if test -d $d -o -L $d
            fish_add_path $d
        end
    end
end
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end
# } General


# Homebrew {
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end
# } Homebrew


# LS_COLORS {
if test -r $HOME/.config/dircolors/dircolors
    if type --query gdircolors
        set --export LS_COLORS (gdircolors -b $HOME/.config/dircolors/dircolors | head -n 1 | string sub --start 12 --end -2)
    else if type --query dircolors
        set --export LS_COLORS (dircolors -b $HOME/.config/dircolors/dircolors | head -n 1 | string sub --start 12 --end -2)
    end

    if type --query gls
        alias ls "gls --color=auto --quoting-style=literal"
    else
        alias ls "ls --color=auto --quoting-style=literal"
    end
end
# } LS_COLORS


# fd-find {
if type --query fdfind
    alias fd fdfind
end

switch (string lower (uname -o))
    case "cygwin*" "msys*"
        alias fd "fd --path-separator=//"
end
# } fd-find


# neovim {
if type --query nvim
    set --export EDITOR nvim
    set --export VISUAL nvim
end
# } neovim


# ripgrep {
switch (string lower (uname -o))
    case "cygwin*" "msys*"
        alias rg "rg --path-separator=//"
end
# } ripgrep


# zoxide {
if type --query zoxide
    zoxide init fish | source
end
# } zoxide


# Go {
if test -d $HOME/go/bin
    fish_add_path $HOME/go/bin
end
# } Go


# Node.js {
## nvm.fish https://github.com/jorgebucaran/nvm.fish
if not set --query nvm_default_version
    set --export nvm_default_version lts
end
# } Node.js


# Python {
## User executables
switch (string lower (uname -o))
    case "cygwin*" "msys*"
        if test -d $HOME/AppData/Roaming/Python
            for d in $HOME/AppData/Roaming/Python/*/Scripts
                if test -d $d
                    fish_add_path $d
                end
            end
        end
    case "darwin*"
        if test -d $HOME/Library/Python
            for d in $HOME/Library/Python/*/bin
                if test -d $d
                    fish_add_path $d
                end
            end
        end
        if test -d /Library/Frameworks/Python.framework/Versions/Current/bin
            fish_add_path /Library/Frameworks/Python.framework/Versions/Current/bin
        end
end

## pyenv
if not test -x pyenv; and test -d $HOME/.pyenv
    set --export PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
end
if status --is-interactive; and test -x pyenv
    pyenv init - | source
    pyenv virtualenv-init - | source
end
# } Python


# Android SDK {
if test -d $HOME/Android/Sdk
    set --export ANDROID_HOME $HOME/Android/Sdk
else if test -d $HOME/Library/Android/sdk
    set --export ANDROID_HOME $HOME/Library/Android/sdk
end

if set --query ANDROID_HOME
    fish_add_path $ANDROID_HOME/tools
    fish_add_path $ANDROID_HOME/tools/bin
    fish_add_path $ANDROID_HOME/platform-tools
end
# } Android SDK
