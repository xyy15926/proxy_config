#!/usr/bin/env shell
# ---------------------------------------------------------
#   Name: rcaddon.sh
#   Author: xyy15926
#   Created: 2025-06-04 11:48:41
#   Updated: 2025-06-19 10:30:09
#   Description:
# ---------------------------------------------------------

# Set ROOT path.
PROXY_ROOT="$HOME/code/proxy_config"
# Vi-edit-mode.
set -o vi

# >>>>>>>>>>>>>>>>>>>>>>>>> Some aliases >>>>>>>>>>>>>>>>>>>>>>>>>>>>
alias rm="rm -i"
alias ls="ls --group-directories-first --color"
alias ll="ls --group-directories-first --color -l"
alias la="ls --group-directories-first --color -l -a"
alias ipythonn="ipython --no-autoindent"
alias pargs="xargs -p"
alias grep="grep -n -H --color=always"
# Ref:
# - `xargs`'s tutorial: https://www.ruanyifeng.com/blog/2019/08/xargs-tutorial.html
# - Params for `alias`: https://forsworns.github.io/zh/blogs/20190919/
alias xgrep='grep_(){ find $1 -name $2 -print0 | xargs -0 grep -n -H --color=always $3; }; grep_'
alias tboard="tensorboard --logir=$PROXY_ROOT/../aki7proj/tmp"


# >>>>>>>>>>>>>>>>>>>>>>>>> Gtags >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if [ -f $HOME/.globalrc ] && hash gtags 2>/dev/null; then
	export GTAGSLABEL="native-pygments"
	export GTAGSCONF="$HOME/.globalrc"
fi

# >>>>>>>>>>>>>>>>>>>>>>>>> Vim >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if [ -d "/opt/vim/bin" ]; then
	export PATH="/opt/vim/bin:$PATH"
fi

# >>>>>>>>>>>>>>>>>>>>>>>>> Forge or Conda >>>>>>>>>>>>>>>>>>>>>>>>>>
# Init conda or forge for shell interaction.
# 1. `mamba shell init` will generate the block in the shell rc.
if [ -d "/opt/miniforge3" ]; then
	export MAMBA_EXE='/opt/miniforge3/bin/mamba';
	export MAMBA_ROOT_PREFIX='/opt/miniforge3';
	__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
	if [ $? -eq 0 ]; then
		eval "$__mamba_setup"
	else
		alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
	fi
	unset __mamba_setup
	if [[ $(mamba env list | grep aki7) != "" ]]; then
		mamba deactivate && mamba activate aki7
	else
		mamba activate base
	fi
# 2. `conda init` will generate the block in the shell rc.
elif [ -d "/opt/miniconda3" ]; then
	__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
	if [ $? -eq 0 ]; then
		eval "$__conda_setup"
	else
		if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
			. "/opt/miniconda3/etc/profile.d/conda.sh"
		else
			export PATH="/opt/miniconda3/bin:$PATH"
		fi
	fi
	unset __conda_setup
	if [[ $(conda env list | grep aki7) != "" ]]; then
		conda deactivate && conda activate aki7
	else
		mamba activate base
	fi
fi

# >>>>>>>>>>>>>>>>>>>>>>>>>>>> z.sh >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Ref:
# -	Usage: https://zhuanlan.zhihu.com/p/50548459
# - Repo: https://github.com/rupa/z
if [ -f "$PROXY_ROOT/shell/z.sh" ]; then
	source "$PROXY_ROOT/shell/z.sh"
	alias zc="z -c"
fi
unset $PROXY_ROOT

# >>>>>>>>>>>>>>>>>>>>>>>>>>> Proxy In WSL2 >>>>>>>>>>>>>>>>>>>>>>>>>
# Ref:
# - https://dslztx.github.io/blog/2017/05/19/ssh%E5%91%BD%E4%BB%A4%E4%B9%8BProxyCommand%E9%80%89%E9%A1%B9/
# Just export a environment variable for SSH config.
# export CLASH_PROXY="$(ip neighbor | cut -d \  -f 1 | head -n 1):7890"
export CLASH_PROXY="127.0.0.1:7890"
# Set global proxy `ALL_PROXY` only when necessary.
export ALL_PROXY="http://$CLASH_PROXY"
