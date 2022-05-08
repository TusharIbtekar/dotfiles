#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install htop curl neofetch tree -y

# install zsh
sudo apt install zsh -y

# change default shell to zsh
chsh -s $(which zsh)

# symlink .zshrc
ln -s ~/dotfiles/.zshrc ~/.zshrc

# symlink .config
ln -s ~/dotfiles/.config/* ~/.config

# symlink .gitconfig
ln -s ~/dotfiles/.gitconfig ~/.gitconfig

# install exa
sudo apt install exa -y

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# then install preferred nodejs version manually

# manually add git ssh key