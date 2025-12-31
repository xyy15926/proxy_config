#!/usr/bin/env bash
# ---------------------------------------------------------
#   Name: setup.sh
#   Author: xyy15926
#   Created: 2025-06-04 08:35:54
#   Updated: 2025-12-18 19:13:40
#   Description:
# ---------------------------------------------------------
set +e
set -x
ROOT=$(dirname $(readlink -f "$0"))
echo "Config file in $ROOT will be used to init current user environment."

# >>>>>>>>>>>>>>>>>>>>> Shell RC addon >>>>>>>>>>>>>>>>>>>>>>>>>>
ln -s "$ROOT/shell/rcaddon.sh" "$HOME/.$(basename $SHELL)_aliases"
# echo '. $HOME/.'."$(basename $SHELL)_aliases" >> "$HOME/.$(basename $SHELL)rc"
ln -s $ROOT/shell/inputrc.sh $HOME/.inputrc
if [ -f "$ROOT/tmux/tmux.conf" ] && hash tmux 2>/dev/null; then
	ln -s $ROOT/tmux/tmux.conf $HOME/.tmux.conf
fi

# >>>>>>>>>>>>>>>>>>>>> Apt >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if hash apt 2>/dev/null; then
	if [[ $(lsb_release -a | grep -i ubuntu) != "" ]] && [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
		sudo mv "/etc/apt/sources.list.d/ubuntu.sources" "/etc/apt/sources.list.d/ubuntu.sources.bak"
		sudo ln -s "$ROOT/apt/tsinghua_ubuntu.sources" "/etc/apt/sources.listd.d/tsinghua_ubuntu.sources"
	fi
fi

# >>>>>>>>>>>>>>>>>>>>> Pixi >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if ! [ -d "$HOME/.pixi" ]; then
	curl -fsSL https://pixi.sh/install.sh | sh
	pixi config set detached-environment false
	pixi config set pypi-config.index-url "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"
	pixi config append pypi-config.extra-index-urls "https://mirrors.aliyun.com/pypi/simple"
	pixi config append pypi-config.extra-index-urls "https://pypi.org/simple"
	pixi config prepend default-channels "https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge"
	# pixi coinfg append default-channels "https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main"
	# pixi coinfg append default-channels "https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free"
	# pixi coinfg append default-channels "https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r"
	# pixi coinfg append default-channels "https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2"
	echo "" >> "$HOME/.pixi/config.toml"
	echo "[mirrors]" >> "$HOME/.pixi/config.toml"
	echo "\"https://conda.anaconda.org/\" = [\"https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/\"]" >> "$HOME/.pixi/config.toml"
	pixi global install python ipython -e dev		# Global python env For vim-plugins
	pixi global add ruff pygments -e dev
fi

# # >>>>>>>>>>>>>>>>>>>> Python releases >>>>>>>>>>>>>>>>>>>>>>>>>
# PYENV="aki7"
# if ! [ -d "/opt/miniforge3" ]; then
# 	if ! [ -d "$ROOT/tmp" ]; then
# 		mkdir "$ROOT/tmp"
# 	fi
# 	cd "$ROOT/tmp"
# 	curl -L "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" -o "$ROOT/tmp/Miniforge3.sh"
# 	sudo "$ROOT/tmp/Miniforge3.sh" -s -p "/opt/miniforge3"
# fi
# # Mamba has to be initialized in the shell for the script's execution.
# if [ -d "/opt/miniforge3" ]; then
# 	export MAMBA_EXE='/opt/miniforge3/bin/mamba';
# 	export MAMBA_ROOT_PREFIX='/opt/miniforge3';
# 	__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
# 	if [ $? -eq 0 ]; then
# 		eval "$__mamba_setup"
# 	else
# 		alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
# 	fi
# 	unset __mamba_setup
# 	if [[ $(mamba env list | grep $PYENV) != "" ]]; then
# 		mamba deactivate && mamba activate $PYENV
# 	else
# 		mamba activate base
# 	fi
# fi
# if hash mamba 2>/dev/null && hash pip 2>/dev/null; then
# 	if [[ $(mamba env list | grep $PYENV) == "" ]]; then
# 		mamba config set show_channel_urls yes
# 		mamba config prepend envs_dirs "$HOME/.mamba/envs"
# 		mamba config prepend pkgs_dirs "$HOME/.mamba/pkgs"
# 		# Set `conda-forge` as the default channel.
# 		# Ref:
# 		#   - https://blog.csdn.net/Code_LT/article/details/134928013
# 		mamba config prepend channels "conda-forge"
# 		# sudo chmod 777 "/opt/miniforge3/envs" "/opt/miniforge3/pkgs" "/opt/miniforge3/pkgs/cache"
# 		mamba create -n $PYENV numpy pandas scipy scikit-learn ipython pytest flake8
# 		mamba install -n $PYENV tqdm pyecharts SQLAlchemy openpyxl jieba pdfplumber networkx xgboost
# 		mamba install -n $PYENV pytorch
# 		# mamba install -n $PYENV PyMySQL streamlit tensorboard
# 		# mamba install -n $PYENV isort black
# 	fi
# 	mamba activate $PYENV
# 	pip install -i "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple" --upgrade pip
# 	pip config set global.index-url "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"
# fi

# >>>>>>>>>>>>>>>>>>>>> Vim dev environment >>>>>>>>>>>>>>>>>>>>>
if [ -d "$ROOT/vim" ] && ! [ -e "$HOME/.vim" ] && hash vim 2>/dev/null; then
# if [ -d "$ROOT/vim" ] && hash vim 2>/dev/null; then
	ln -s $ROOT/vim $HOME/.vim
	mkdir $ROOT/vim/swaps
	mkdir $ROOT/vim/backups
	mkdir $ROOT/vim/cache/
	# vim +PlugInstall +qall
	vim +PlugInstall
fi
if ! hash global 2>/dev/null; then
	sudo apt update
	sudo apt install global universal-ctags
	sudo ln -s "$ROOT/gtags/pygments_parser.py" "/usr/share/global/gtags/script/pygments_parser.py"
	# if hash mamba 2>/dev/null && hash pip 2>/dev/null; then
	# 	# mamba activate $PYENV
	# 	# pip install pygments
	# 	mamba install -n $PYENV pygments
	# fi
fi
if [ -f "$ROOT/gtags/gtags.conf" ] && hash global 2>/dev/null; then
	ln -s $ROOT/gtags/gtags.conf $HOME/.globalrc
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

# >>>>>>>>>>>>>>>>>>>>>>>>>>> Git >>>>>>>>>>>>>>>>>>>>>>>>>>>>
if hash git 2>/dev/null; then
	ln -s "$ROOT/git/gitconfig" "$HOME/.gitconfig"
	ln -s "$ROOT/ssh/config" "$HOME/.ssh/config"
	# The proxy host should be the firewall for WSL2.
	# firewall="http://$(ip neighbor | cut -d \  -f 1 | head -n 1):7890"
	firewall="127.0.0.1:7890"
	if [ -z $firewall ]; then
		git config --global https.proxy $firewall
		git config --global http.proxy $firewall
		git config --global --unset https.proxy $firewall
		git config --global --unset http.proxy $firewall
	fi
fi

# >>>>>>>>>>>>>>>>>>>>>>>>>>> Tmux >>>>>>>>>>>>>>>>>>>>>>>>>>>
if ! hash tmux 2>/dev/null; then
	sudo apt update
	sudo apt install tmux
fi
if [ -f "$ROOT/tmux/tmux.conf" ] && hash tmux 2>/dev/null; then
	ln -s $ROOT/tmux/tmux.conf $HOME/.tmux.conf
fi

# >>>>>>>>>>>>>>>>>>>>>>>>>> PyPI >>>>>>>>>>>>>>>>>>>>>>>>>>>>
if [ -f "$ROOT/pypi/pypirc" ]; then
	ln -s $ROOT/pypi/pypirc $HOME/.pypirc
fi

# >>>>>>>>>>>>>>>>>>>>>>>>> rust >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
export RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"
if hash curl 2>/dev/null; then
	curl --proto "=https" --tlsv1.2 "https://sh.rustup.rs -sSf" | sh
	# Add rust-analyzer, rustfmt
	rustup component add rust-analyzer
	rustup component add rustfmt
fi

