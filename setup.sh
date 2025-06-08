#!/usr/bin/env bash
# ---------------------------------------------------------
#   Name: setup.sh
#   Author: xyy15926
#   Created: 2025-06-04 08:35:54
#   Updated: 2025-06-08 21:22:55
#   Description:
# ---------------------------------------------------------
set +e
ROOT=$(dirname $(readlink -f "$0"))
echo "Config file in $ROOT will be used to init current user environment."

# Dependencies.
if ! [ -d "/opt/miniforge3" ]; then
	if ! [ -d "$ROOT/tmp" ]; then
		mkdir "$ROOT/tmp"
	fi
	cd "$ROOT/tmp"
	curl -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
	cd "$ROOT"
fi
if ! hash global 2>/dev/null; then
	sudo apt update
	sudo apt install global
	# pip install pygments
	# sudo ln -s "$ROOT/gtags/pygments_parser.py" "/usr/share/global/gtags/script/pygments_parser.py"
	# mamba install flake8 isort black
fi
if ! hash rg 2>/dev/null; then
	sudo apt update
	sudo apt install ripgrep
fi

# Some symbolic link for configs.
if [ -f "$ROOT/rcaddon.sh" ]; then
	DEFAULT_SHELL=$(basename $SHELL)
	ln -s $ROOT/rcaddon.sh $HOME/.${DEFAULT_SHELL}_aliases
fi
if [ -d "$ROOT/vim" ] && ! [ -e "$HOME/.vim" ] && hash vim 2>/dev/null; then
# if [ -d "$ROOT/vim" ] && hash vim 2>/dev/null; then
	ln -s $ROOT/vim $HOME/.vim
	mkdir $ROOT/vim/swaps
	mkdir $ROOT/vim/backups
	mkdir $ROOT/vim/cache/
	vim +PlugInstall +qall
fi
if [ -f "$ROOT/gtags/gtags.conf" ] && hash global 2>/dev/null; then
	ln -s $ROOT/gtags/gtags.conf $HOME/.globalrc
fi
if [ -f "$ROOT/tmux/tmux.conf" ] && hash tmux 2>/dev/null; then
	ln -s $ROOT/tmux/tmux.conf $HOME/.tmux.conf
fi
if [ -f "$ROOT/gitconfig" ] && hash git 2>/dev/null; then
	ln -s $ROOT/gitconfig $HOME/.gitconfig
fi
