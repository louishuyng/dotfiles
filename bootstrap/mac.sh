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

load_pre_script() {
  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
  success "Built Locate Database"

  mkdir -p ~/sys_log/
  touch ~/sys_log/attacker.log

  cd ~/.dotfiles/scripts/ssh && \
    cp -i sshrc  ~/.ssh/

  success "Setup sshrc config"

  sudo mdutil -ai off

  success "Turn off spotlight index"
}

install_homebrew() {
  read -r -p "Do you want to install homebrew? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    git clone https://github.com/Homebrew/brew homebrew
    brew update --force --quiet
    eval "$(homebrew/bin/brew shellenv)"

    chmod -R go-w "$(brew --prefix)/share/zsh"

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap homebrew/cask
    
    success "Installed homebrew"
  fi
}

setup_git() {
  read -r -p "Do you want to setup git? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install gh 
    success "Installed GitHub CLI"
    
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

install_languages() {
  read -r -p "Do you want to install languages? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install asdf
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
    asdf install golang latest
    success "Installed golang"

    asdf plugin-add ruby
    asdf install ruby latest
    asdf global ruby 3.1.1
    success "Installed ruby"
  fi
}

install_devops() {
  read -r -p "Do you want to install devops tools? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install docker --cask
    brew install lazydocker
    success "Installed docker"

    brew install helm
    brew install kubectx
    brew install k9s
    ln -s ~/.dotfiles/suckless/k9s /Users/louishuyng/Library/Application\ Support
    success "Installed k8s"

    brew install pstree
    success "Installed pstree"

    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    brew install hashicorp/tap/terraform-ls # LSP

    success "Installed terraform"
  fi
}

setup_penetration_tools() {
  read -r -p "Do you want to install some penetration tools ? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install owasp-zap
    brew install nmap
    brew install openconnect
    brew install openvpn

    chmod +x ./tools/beef/install
    ./tools/beef/install

    success "Installed penetration tools"
  fi
}

install_fish() {
  read -r -p "Do you want to install fish? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install fish
    curl -sL https://git.io/fisher | source

    sudo chsh -s "$(which fish)"
    fisher update
    
    success "Installed fish"
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

    # Better font display on Mac
    defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO

    success "Installed font!"
  fi
}

install_terminal() {
  read -r -p "Do you want to install kitty? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install --cask kitty

    success "Installed kitty terminal"

    brew install neofetch

    success "Installed neofetch"
  fi
}

install_mailspring() {
  read -r -p "Do you want to install mailspring? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install --cask mailspring

    rm -rf ~/.dotfiles/suckless/mailspring
    git clone https://github.com/jakubzet/mailspring-matcha-theme.git ~/.dotfiles/suckless/mailspring 
    
    ln -s ~/.dotfiles/suckless/mailspring ~/
    success "Installed mailspring and custom theme"
  fi
}

install_ninja() {
  read -r -p "Do you want to install ninja and lua lsp? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install ninja

    cd ~/.dotfiles/nvim
    git clone https://github.com/sumneko/lua-language-server
    cd lua-language-server
    git submodule update --init --recursive

    cd 3rd/luamake
    compile/install.sh
    cd ../..
    ./3rd/luamake/luamake rebuild

    brew install luarocks
    luarocks install --server=https://luarocks.org/dev luaformatter

    success "Installed nija and setup lua lsp"
  fi
}

install_nvim() {
  read -r -p "Do you want to install neovim? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    info "Installing neovim"
    brew install lua
    brew install neovim

    success "Installed neovim"
  fi
}

install_emacs() {
  read -r -p "Do you want to install emacs? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    info "Installing emacs"
    brew install --cask emacs
    brew tap d12frosted/emacs-plus
    brew install emacs-plus --with-no-titlebar

    success "Installed emacs"
  fi
}

install_tmux() {
  read -r -p "Do you want to install tmux? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install tmux
    brew install tmuxinator

    rm ~/.tmux.conf

    ln -s ~/.dotfiles/terminal/tmuxinator -t ~/.config/tmuxinator

    rm -rf ~/.tmux/plugins/tpm
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
}

install_key_bindings() {
  read -r -p "Do you want to install karabiner? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install --cask karabiner-elements

    success "Installed karabiner"
  fi
}

install_window_manager() {
  read -r -p "Do you want to install window manager? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install koekeishiya/formulae/yabai --HEAD
    codesign -fs 'yabai-cert' "$(which yabai)"

    sudo yabai --install-sa

    brew services start yabai
    killall Dock

    brew tap FelixKratz/formulae
    brew install sketchybar

    chmod +x ~/.dotfiles/scripts/*

    brew install koekeishiya/formulae/skhd
    brew services start skhd

    success "Installed window manager! Remember to disable System Integrity Protection (SIP)"
  fi
}

install_qutebrowser() {
  read -r -p "Do you want to install qutebrowser? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install qutebrowser --cask
  fi
}

install_nnn() {
  read -r -p "Do you want to install qutebrowser? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    cd /tmp
    git clone git@github.com:jarun/nnn.git
    cd nnn

    # Build with nerd icon
    make O_NERD=1 

    sudo cp nnn /usr/local/bin
    rm -rf  /tmp/nnn
  fi
}

install_nixos() {
  read -r -p "Do you want to install nixos? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    curl -L https://nixos.org/nix/install | sh

    ln -s ~/.dotfiles/nix ~/.config/nix
  fi
}

link_all_dotfiles() {
  brew install stow

  rm ~/.tmux.conf
  rm -rf ~/.zshrc

  mkdir -p ~/.config/kitty
  mkdir -p ~/.config/fish

  cd ~/.dotfiles/terminals && \
    stow kitty -t ~/.config/kitty && \
    stow fish -t ~/.config/fish && \
    stow tmux -t ~/ && \
    stow neofetch ~/.config/neofetch \
  success "Linked terminals"

  mkdir -p ~/.config/nvim
  cd ~/.dotfiles && stow nvim -t ~/.config/nvim
  success "Linked neovim"

  cd ~/.dotfiles && stow emacs -t ~/
  success "Linked emacs"

  rm -rf ~/.skhdrc
  rm -rf ~/.yabairc
  cd ~/.dotfiles/suckless/mac_os && stow yabai -t ~/ && stow skhdrc -t ~/
  ln -s ~/.dotfiles/suckless/mac_os/sketchybar ~/.config

  success "Linked window manager"

  rm -rf ~/.qutebrowser
  ln -s ~/.dotfiles/suckless/qutebrowser ~/.qutebrowser

  success "Linked qutebrowser"

  mkdir -p ~/.config/bpytop
  cd ~/.dotfiles/suckless && stow nnn -t ~/.config && stow bpytop -t ~/.config/bpytop

  success "Linked other tools"

  ln -s ~/.dotfiles/suckless/git/.gitconfig ~/.gitconfig
  success "Linked git config"

  stow karabiner -t ~/.config/karabiner
  ln -s ~/.dotfiles/suckless/mac_os/karabiner ~/.config
  
  success "Linked git config"

  ln -s ~/.dotfiles/.ideavimrc ~/
  success "Linked ideavimrc"
}

install_cli_tools() {
  read -r -p "Do you want to install cli for tools? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]];then
    brew install --cask unnaturalscrollwheels
    brew install act # github action test locally
    brew install asciinema
    brew install autojump
    brew install bpytop
    brew install brightness
    brew install diff-so-fancy
    brew install fzf
    brew install graphviz
    brew install gum
    brew install isacikgoz/taps/tldr
    brew install jq
    brew install pgcli
    brew install ripgrep
    brew install terminal-notifier
    brew tap daipeihust/tap                                                                                                                                                                   louishuyng
    brew install im-select
    brew install git-delta

    # Devops
    brew install bat # Better cat
    brew install exa # Better ls
    brew install fd # Better find
    brew install dust # Better checking size
    brew install sd # Better sed
    brew install pidof # Better check process id of program
    brew install dog # Better dig dns networking
    brew install xh # Better curl 
    brew install ncdu # Better du
    brew install duf # Better du
    brew install jqp # Visualise jq
    brew install fastmod # Fast partial replacement 
    brew install watch
    brew install ansifilter # Program specialized for removing (or working with) ANSI codes 
    brew install xdg-ninja # A shell script which checks your $HOME for unwanted files and directories.

    success "Installed cli for tools"

    brew tap FelixKratz/formulae
    brew install svim

    ln -s ~/.dotfiles/suckless/mac_os/svim ~/.config

    brew services start svim

    success "Installed vim mode for macos input"
  fi
}

default_setting_macos() {
  echo "- Setting up macOS"
  ## macOS Settings

  ## Appearance & Animations

  # Use Graphite Appearance
  defaults write NSGlobalDomain AppleAquaColorVariant -int 6

  # Use Graphite Highlight Color
  defaults write NSGlobalDomain AppleHighlightColor -string "0.780400 0.815700 0.858800"


  ## Keyboard

  # Set fast key repeat
  defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
  defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  ## Mouse
  
  # Set mouse tracking speed to reasonably fast
  defaults write NSGlobalDomain com.apple.mouse.scaling -float 2

  # Tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking 1
  defaults write com.apple.AppleMultitouchTrackpad Clicking 1

  ## Finder

  # Disable all animations
  defaults write com.apple.finder DisableAllAnimations -bool true

  ## Menu Bar
  
  ## Don't show battery percentage
  defaults write com.apple.menuextra.battery "ShowPercent" -bool false

  # Hide Spotlight Icon
  defaults write com.apple.Spotlight "NSStatusItem Visible Item-0" 0

  ### Spaces
  
  # Don’t automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false

  ### Screen Shots

  # Move screen shots to ~/Screen Shots
  mkdir -p ~/Screen\ Shots
  defaults write com.apple.screencapture location ~/Screen\ Shots

  echo "- Restarting SystemUIServer"
  killall SystemUIServer
}

load_pre_script

install_homebrew
setup_git
install_languages
install_devops
setup_penetration_tools
install_fish
install_font
install_terminal
install_mailspring
install_ninja
install_nvim
install_emacs
install_tmux
install_window_manager
install_qutebrowser
install_nnn
link_all_dotfiles
install_cli_tools
default_setting_macos

echo "---"

echo "Finish Install!"
