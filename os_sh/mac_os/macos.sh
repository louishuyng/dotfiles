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
    brew tap caskroom/cask
    success "Installed homebrew"
  fi
}

install_brew_list() {
  read -r -p "Do you want to install brew list? [y|N] " response
  if [[ $response =~ (y|yes|y) ]];then
    cat ./packages.txt | xagrs brew install
    cat ./packages_cask.txt  | xagrs brew cask install
    success "Installed homebrew list"
  fi
}

setup_git() {
  read -r -p "Do you want to setup git? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    git config --global user.email "huynguyennbk@gmail.com" 
    git config --global user.name "Huy Nguyen" 
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

install_ubersicht() {
  read -r -p "Do you want to install ubersicht status bar? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew cask install ubersicht
    cp -r ../../Ubersicht/* ~/Library/Application Support/Übersicht
    success "Installed ubersicht status bar"
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
    success "Installed font powerline!"
  fi
}

map_hot_keys_config() {
  read -r -p "Do you want to map hot keys? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    touch ~/.chunkwmrc
    touch ~/.skhdrc
    cd ../../skhdrcConfig
    ln -s /.chunkwmrc ~/.chunkwmrc
    ln -s /.skhdrc ~/.chunkwmrc
    success "Mapped hot keys!"
  fi
}

install_homebrew
install_brew_list
setup_git
install_ubersicht

echo "---" 

echo "Finish Install!"
#! /bin/bash
