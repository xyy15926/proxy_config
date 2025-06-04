#!/usr/bin/env bash
# ---------------------------------------------------------
#	Name: setup.sh
#	Author: xyy15926
#	Created: 2025-06-04 08:35:54
updated: 2025-06-04 11:22:28
#	Description:
# ---------------------------------------------------------
set +e
ROOT=$(dirname $(readlink -f "$0"))
echo "Config file in $ROOT will be used to init current user environment."

# Some symbolic link for configs.
if [ -f "$ROOT/rcaddon.sh" ]; then
	DEFAULT_SHELL=$(basename $SHELL)
	ln -s $ROOT/rcaddon.sh $HOME/.${DEFAULT_SHELL}_aliases
fi
# if [ -d "$ROOT/vim" ] && ! [ -e "$HOME/.vim" ] && hash vim 2>/dev/null; then
if [ -d "$ROOT/vim" ] && hash vim 2>/dev/null; then
	ln -s $ROOT/vim $HOME/.vim
	mkdir $ROOT/vim/swaps
	mkdir $ROOT/vim/backups
	vim +PlugInstall +qall
fi
if [ -f "$ROOT/globalrc" ] && hash global 2>/dev/null; then
	ln -s $ROOT/globalrc $HOME/.globalrc
fi
if [ -f "$ROOT/tmux/tmux.conf" ] && hash tmux 2>/dev/null; then
	ln -s $ROOT/tmux/tmux.conf $HOME/.tmux.conf
fi
if [ -f "$ROOT/gitconfig" ] && hash git 2>/dev/null; then
	ln -s $ROOT/gitconfig $HOME/.gitconfig
fi
