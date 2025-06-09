#!/usr/bin/env shell
# ---------------------------------------------------------
#   Name: rcaddon.sh
#   Author: xyy15926
#   Created: 2025-06-04 11:48:41
#   Updated: 2025-06-09 10:14:05
#   Description:
# ---------------------------------------------------------

# Set ROOT path.
PROXY_ROOT="$HOME/code/proxy_config"

# Vi-edit-mode.
set -o vi

# Menu-Complete: cycle through the possibles.
# Ref:
# -	https://unix.stackexchange.com/questions/24419/terminal-autocomplete-cycle-through-suggestions
# - https://stackoverflow.com/questions/12044574/getting-complete-and-menu-complete-to-work-together
set show-all-if-ambiguous on
set show-all-if-unmodified on
set menu-complete-display-prefix on
# Cycle forward: TAB.
bind TAB:menu-complete
# Cycle backward: Shift-TAB.
# bind '"\e[Z":menu-complete-backward'
# # List possibles
bind '"\e[Z":complete'

# Some aliases.
alias rm="rm -i"
alias ls="ls --group-directories-first --color"
alias ll="ls --group-directories-first --color -l"
alias la="ls --group-directories-first --color -l -a"
alias ipythonn="ipython --no-autoindent"

# Some simple global environment variables.
if [ -f $HOME/.globalrc ] && hash gtags 2>/dev/null; then
	export GTAGSLABEL="native-pygments"
	export GTAGSCONF="$HOME/.globalrc"
fi
if [ -d "/opt/vim/bin" ]; then
	export PATH="/opt/vim/bin:$PATH"
fi

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
	fi
fi

# Source z.sh
# Ref:
# -	Usage: https://zhuanlan.zhihu.com/p/50548459
# - Repo: https://github.com/rupa/z
if [ -f "$PROXY_ROOT/shell/z.sh" ]; then
	source "$PROXY_ROOT/shell/z.sh"
fi

unset $PROXY_ROOT
