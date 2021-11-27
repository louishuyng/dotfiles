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

install_libs() {
  read -r -p "Do you want to upgrade lib? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    sudo apt-get install && sudo apt-get upgrade
    sudo apt-get install build-essential
    
    success "Upgrade Lib"
  fi
}

install_ninja() {
  read -r -p "Do you want to install ninja and lua lsp? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    sudo apt install ninja-build
    
    cd ~/.dotfiles/nvim
    git clone https://github.com/sumneko/lua-language-server
    cd lua-language-server
    git submodule update --init --recursive

    cd 3rd/luamake
    compile/install.sh
    cd ../..
    ./3rd/luamake/luamake rebuild
    
    success "Installed nija and setup lua lsp"
  fi
}

setup_git() {
  read -r -p "Do you want to setup git? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    git config --global user.email "huynguyennbk@gmail.com"
    git config --global user.name  "Louis Nguyen"
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

    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status

    success "Setup Git Successfully"
  fi
}

install_zsh() {
  read -r -p "Do you want to install zsh? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    sudo apt-get install zsh -y

    sudo apt install peco
    sudo chsh -s $(which zsh)
    zsh

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

    success "Installed font!"
  fi
}

install_nvim() {
  read -r -p "Do you want to install neovim? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    info "Installing neovim"
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install neovim

    sudo apt-get install -y python-dev python-pip python3-dev python3-pip
    success "Installed neovim"
  fi
}

install_tools() {
  read -r -p "Do you want to install some fancy tools ? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    sudo apt-get install -y nnn

    echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
    wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
    sudo apt install bpytop
    sudo apt install fzf

    success "Installed some fancy tools"
  fi
}

link_all_dotfiles() {
  sudo apt-get update -y
  sudo apt-get install -y stow

  rm -rf ~/.zshrc

  cd ~/.dotfiles/terminals && stow zsh -t ~/
  success "Linked terminals"

  mkdir -p ~/.config/nvim
  cd ~/.dotfiles && stow nvim -t ~/.config/nvim
  success "Linked neovim"

  cd ~/.dotfiles && stow emacs -t ~/
  success "Linked emacs"

  mkdir -p ~/.config/bpytop
  cd ~/.dotfiles/suckless && stow nnn -t ~/.config && stow bpytop -t ~/.config/bpytop

  success "Linked other tools"
}

install_libs
install_ninja
setup_git
install_zsh
install_font
install_nvim

echo "---"

echo "Finish Install!"
