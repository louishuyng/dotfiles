#! /bin/bash
echo "---"

set -e

info () {
  printf "\r  [\033[00;34m..\033[0m] %s \n" "$1"
}

user () {
  printf "\r  [\033[0;33m??\033[0m] %s \n" "$1"
}

success () {
  printf "\r\033[2K [\033[00;32mOK\033[0m] %s \n" "$1"
}

fail () {
  printf "\r\033[2K [\033[0;31mFAIL\033[0m] %s \n" "$1"
  echo ''
  exit
}

install_libs() {
  read -r -p "Do you want to upgrade lib? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    sudo pacman -Syu
    sudo pacman -S base-devel fakeroot jshon expac git wget
    wget 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=packer'
    mv PKGBUILD\?h=packer PKGBUILD
    makepkg
    sudo pacman -U packer-*.pkg.tar.zst

    sudo pacman -S base-devel
    
    success "Upgrade Lib"
  fi
}

install_ninja() {
  read -r -p "Do you want to install ninja and lua lsp? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    sudo pacman -S lua
    packer -S ninja
    
    cd ~/.dotfiles/nvim
    git clone https://github.com/sumneko/lua-language-server
    cd lua-language-server
    git submodule update --init --recursive

    cd 3rd/luamake
    compile/install.sh
    cd ../..
    ./3rd/luamake/luamake rebuild

    sudo pacman -S luarocks
    luarocks install --server=https://luarocks.org/dev luaformatter
    
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

    git config --global pull.rebase true
    git config --global rebase.autoStash true

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
    sudo pacman -S zsh

    sudo pacman -S peco
    chsh -s /bin/zsh
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
    sudo pacman -S neovim

    packer -S nvim-packer-git

    git clone https://github.com/wbthomason/packer.nvim "$(env:LOCALAPPDATA)\nvim-data\site\pack\packer\start\packer.nvim"
    sudo pacman -S python-pip

    success "Installed neovim"
  fi
}

install_languages() {
  read -r -p "Do you want to install languages? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si
    success "Installed asdf"

    asdf plugin-add rust
    asdf install rust 1.55.0
    asdf global rust 1.55.0
    success "Installed rust"

    asdf plugin-add python
    asdf install python 3.7.3
    asdf global python 3.7.3
    success "Installed python"

    asdf plugin-add golang
    asdf install golang 1.17.3
    asdf global golang 1.17.3
    mkdir "$HOME"/go
    success "Installed golang"
  fi
  
}

install_tools() {
  read -r -p "Do you want to install some fancy tools ? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    sudo pacman -S nnn
    sudo pacman -S bpytop
    sudo pacman -S fzf
    sudo pacman -S neofetch
    sudo pacman -S shellcheck
    sudo pacman -S rustscan
    sudo pacman -S osquery
    sudo pacman -S glow
    sudo pacman -S gum

    go get github.com/isacikgoz/tldr/cmd/tldr

    success "Installed some fancy tools"
  fi
}

link_all_dotfiles() {
  sudo pacman -S stow

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

  ln -s ~/.dotfiles/suckless/git/.gitconfig ~/.gitconfig
  success "Linked git config"
}

install_libs
setup_git
install_ninja
install_zsh
install_font
install_nvim
link_all_dotfiles
install_languages
install_tools

echo "---"

echo "Finish Install!"
