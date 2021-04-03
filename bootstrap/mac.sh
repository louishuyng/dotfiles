#! /bin/bash
echo "---"

DOTFILES_ROOT=$(pwd -P)
set -e

info () {
  printf "\r  [\033[00;34m..\033[0m] $1\n"
}

user () {
  printf "\r  [\033[0;33m??\033[0m] $1\n"
}

success () {
  printf "\r\033[2K [\033[00;32mOK\033[0m] $1\n"
}

fail () {
  printf "\r\033[2K [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

install_homebrew() {
  read -r -p "Do you want to install homebrew? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap homebrew/cask
    success "Installed homebrew"
  fi
}

setup_git() {
  read -r -p "Do you want to setup git? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    git config --global user.email"huynguyennbk@gmail.com"
    git config --global user.name "Louis Nguyen"
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    git config --global color.ui true
    git config --global color.diff-highlight.oldNormal "red bold"
    git config --global color.diff-highlight.oldHighlight "red bold 52"
    git config --global color.diff-highlight.newNormal "green bold"
    git config --global color.diff.meta "11"
    git config --global color.diff.frag "magenta bold"
    git config --global color.diff.commit "yellow bold"
    git config --global color.diff.old "red bold"
    git config --global color.diff.new "green bold"
    git config --global color.diff.whitespace "red reverse"

    success "Setup Git Successfully"
  fi
}
install_zsh() {
  read -r -p "Do you want to install zsh? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install zsh
    sudo chsh -s $(which zsh)

    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    mkdir -p ~/.oh-my-zsh

    rm -rf ~/.zshrc
    ln ../suckless/zsh/.zshrc ~/.zshrc

    rm -rf ~/.zsh-defer
    git clone https://github.com/romkatv/zsh-defer.git ~/.zsh-defer

    success "Installed zsh"
  fi
}

install_font() {
  read -r -p "Do you want to install font? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    git clone https://github.com/powerline/fonts.git --depth=1
    cd fonts
    ./install.sh
    cd ..
    rm -rf fonts

    brew tap homebrew/cask-fonts
    brew install font-hack-nerd-font

    success "Installed font!"
  fi
}

install_terminal() {
  read -r -p "Do you want to install terminal? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install alacritty

    rm -rf ~/.alacritty.yml
    ln ../suckless/mac_os/alacritty/alacritty.yml ~/.alacritty.yml
    success "Installed terminal"
  fi
}

install_nvim() {
  read -r -p "Do you want to install neovim? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    info "Installing neovim"
    brew install --HEAD neovim

    # reduce keyrepeat for faster typing in vim
    defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
    defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

    success "Installed neovim"
  fi
}

install_tmux() {
  read -r -p "Do you want to install tmux? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install tmux
    rm ~/.tmux.conf
    ln ../suckless/tmux/.tmux.conf ~/.tmux.conf

    rm -rf ~/.tmux/plugins/tpm
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
}

install_window_manager() {
  read -r -p "Do you want to install window manager? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install koekeishiya/formulae/yabai
    sudo yabai --install-sa
    brew services start yabai
    killall Dock
    brew install somdoron/formulae/spacebar
    brew services start spacebar
    brew install koekeishiya/formulae/skhd
    brew services start skhd

    rm -rf ~/.skhdrc
    ln ../suckless/mac_os/skhdrc/.skhdrc ~/.skhdrc

    rm -rf ~/.yabairc
    ln ../suckless/mac_os/yabai/.yabairc ~/.yabairc

    rm -rf ~/.spacebarrc
    ln ../suckless/mac_os/spacebar/.spacebarrc ~/.spacebarrc

    success "Installed window manager! Remember to disable System Integrity Protection (SIP)"
  fi
}

install_tool() {
  read -r -p "Do you want to install some fancy tools ? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install ripgrep
    brew install neofetch
    brew install pgcli
    brew install mycli
    brew install bat
    brew install httpie
    brew install diff-so-fancy
    brew install terminal-notifier
    brew install bluetoothconnector
    brew install exa
    brew install fzf
    brew install pidof
    brew install watch

    $(brew --prefix)/opt/fzf/install
    success "Installed some fancy tools"
  fi
}

install_ranger() {
  read -r -p "Do you want to install ranger ? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install ranger
  fi
}


install_lua() {
  read -r -p "Do you want to install lua? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install lua
  fi
}

install_homebrew
setup_git
install_zsh
install_terminal
install_lua
install_nvim
install_tmux
install_window_manager
install_tool
install_ranger

echo "---"

echo "Finish Install!"
