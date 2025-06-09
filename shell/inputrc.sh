#!/usr/bin/env shell
# ---------------------------------------------------------
#   Name: inputrc.sh
#   Author: xyy15926
#   Created: 2025-06-09 21:52:57
#   Updated: 2025-06-09 22:02:59
#   Description:
# ---------------------------------------------------------

# Menu-Complete: cycle through the possibles.
# Ref:
# -	https://unix.stackexchange.com/questions/24419/terminal-autocomplete-cycle-through-suggestions
# - https://stackoverflow.com/questions/12044574/getting-complete-and-menu-complete-to-work-together
# NOTES: Following 3 options won't take effects in `.bashrc`.
# Display all common prefix of the list of possible completions.
set menu-complete-display-prefix on
# List possible completions instead of ringing the bell.
set show-all-if-ambiguous on
# List possible completions instead of ringing the bell even witout partial possible completions.
set show-all-if-unmodified on
# Cycle forward: TAB.
"\t":menu-complete
# Cycle backward: Shift-TAB.
"\e[Z":menu-complete-backward
# NOTES: Following 2 binds also take effects in `.bashrc`.
# bind TAB:menu-complete
# bind '"\e[Z":menu-complete-backward'
