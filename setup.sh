#!/usr/bin/env bash
# ---------------------------------------------------------
#   Name: setup.sh
#   Author: xyy15926
#   Created: 2025-06-04 08:35:54
#   Updated: 2025-06-09 22:43:22
#   Description:
# ---------------------------------------------------------
set +e
set -x
ROOT=$(dirname $(readlink -f "$0"))
echo "Config file in $ROOT will be used to init current user environment."

# >>>>>>>>>>>>>>>>>>>> Python releases >>>>>>>>>>>>>>>>>>>>>>>>>
if ! [ -d "/opt/miniforge3" ]; then
	if ! [ -d "$ROOT/tmp" ]; then
		mkdir "$ROOT/tmp"
	fi
	cd "$ROOT/tmp"
	curl -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
	sudo ./Miniforge3-$(uname)-$(uname -m).sh -s -p "/opt/miniforge3"
	cd "$ROOT"
fi
if hash mamba 2>/dev/null && hash pip 2>/dev/null; then
	python -m pip install -i "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple" --upgrade pip
	pip config set global.index-url "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"
	mamba config prepend envs_dirs "$HOME/.mamba/envs"
	mamba config prepend pkgs_dirs "$HOME/.mamba/pkgs"
	if [[ $(mamba env list | grep aki7) == "" ]]; then
		mamba create -n aki7 numpy pandas scipy scikit-learn ipython pytest flake8
		# mamba install -n aki7 isort black
	fi
fi

# >>>>>>>>>>>>>>>>>>>>> Shell RC addon >>>>>>>>>>>>>>>>>>>>>>>>>>
if [ -f "$ROOT/shell/rcaddon.sh" ]; then
	DEFAULT_SHELL=$(basename $SHELL)
	ln -s $ROOT/shell/rcaddon.sh $HOME/.${DEFAULT_SHELL}_aliases
fi
if [ -f "$ROOT/shell/inputrc.sh" ]; then
	ln -s $ROOT/shell/inputrc.sh $HOME/.inputrc
fi

# >>>>>>>>>>>>>>>>>>>>> Vim dev environment >>>>>>>>>>>>>>>>>>>>>
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
if [ -f "$ROOT/git/gitconfig" ] && hash git 2>/dev/null; then
	ln -s $ROOT/git/gitconfig $HOME/.gitconfig
fi
if ! hash global 2>/dev/null; then
	sudo apt update
	sudo apt install global
	sudo ln -s "$ROOT/gtags/pygments_parser.py" "/usr/share/global/gtags/script/pygments_parser.py"
	if hash mamba 2>/dev/null && hash pip 2>/dev/null; then
		mamba activate aki7
		pip install pygments
	fi
fi
if ! hash rg 2>/dev/null; then
	sudo apt update
	sudo apt install ripgrep
fi
# Ref:
# -	https://github.com/ycm-core/YouCompleteMe?tab=readme-ov-file#linux-64-bit
if [ -f "$ROOT/vim/plugged/YouCompleteMe/install.py" ] && [ -z $(ls "$ROOT/vim/plugged/YouCompleteMe/third_party/ycmd/ycm_core"*) ]; then
	sudo apt update
	sudo apt install build-essential cmake python3-dev
	cd "$ROOT/vim/plugged/YouCompleteMe"
	# Compiling with only basic sematic support.
	/usr/bin/python3 install.py 
	cd $ROOT
fi
