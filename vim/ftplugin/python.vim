"----------------------------------------------------------
"   Name: python.vim
"   Author: xyy15926
"   Created: 2022-11-15 09:58:26
"   Updated: 2022-11-15 09:58:26
"   Description:
"----------------------------------------------------------
"
if exists("b:py_ftplugin")
	finish
endif
let b:py_ftplugin = 1

" Move to next or previous section
nnoremap <buffer> <localleader>mn :<C-u>/^#\ %%\+<CR>
nnoremap <buffer> <localleader>mp :<C-u>?^#\ %%\+<CR>
iabbrev <buffer> #%- 
			\# %% ------------------------------------------------------------------------<CR>
			\#						* * * *  * * * *<CR>
			\# ---------------------------------------------------------------------------

" >>>>>>> For plugin jpalardy/vim-slime >>>>>>>
" packadd vim\-slime
let g:slime_target='vimterminal'
let g:slime_vimterminal_config={
	\ "term_name": "ipython",
	\ "term_cols": 70,
	\ "vertical": 2,
	\ "norestore": 1
	\ }
let g:slime_vimterminal_cmd='ipython --no-autoindent'
let b:slime_cell_delimiter='#\ %%'
nnoremap <buffer> <localleader>sm <Plug>SlimeSendCell:<C-U>/^#\ %%\+<CR>
let g:which_key_map.s.m = "send-cell-next"
" <<<<<<< For plugin jpalardy/vim-slime <<<<<<<

" >>>>>>> For plugin skywind3000/asyncrun >>>>>>>
function! TestPython()
	let abspath = expand("%:p")
	let paths = split(abspath, "/")
	let filename = paths[-1]
	let modname = paths[-2]
	if filename[0:4] ==# "test_"
		execute 'AsyncRun -once -mode=quickfix -cwd="$(VIM_ROOT)" pytest ' . abspath
	elseif filereadable(getcwd() . "/tests/test_" . filename)
		execute 'AsyncRun -once -mode=quickfix -cwd="$(VIM_ROOT)" pytest tests/test_' . filename
	elseif filereadable(getcwd() . "/tests/" . modname . "/test_" . filename)
		execute 'AsyncRun -once -mode=quickfix -cwd="$(VIM_ROOT)" pytest tests/' . modname . '/test_' . filename
	endif
endfunction
nnoremap <buffer> <localleader>xr :AsyncRun python "$(VIM_FILEDIR)/$(VIM_FILENAME)" <CR>
nnoremap <buffer> <localleader>xt :call TestPython()<CR>
" <<<<<<< For plugin skywind3000/asyncrun <<<<<<<

" >>>>>>> For plugin skywind3000/vim-terminal-helper && jpalardy/vim-slime >>>>>>>
" This function will be injected to `SlimeConfig` to override the default
"	behavior.
" Note: related to `s:VimterminalConfig` and `s:SlimeDispatch`
"function SlimeOverrideConfig(...)
"	let bid = get(t:, "__terminal_bid__", -1)
"	let target = substitute(tolower(g:slime_target), '\(.\)', '\u\1', '') " Capitalize
"	if target == 'Vimterminal' && bid > 0
"		if !exists("b:slime_config")
"			let b:slime_config = {"bufnr": ""}
"		endif
"		let b:slime_config["bufnr"] = bid
"	else
"		" `slime.vim` has been modified to check return value.
"		" `-1` represents that this overriding function fails and the
"		"	default process should march on.
"		" And this return require `s:SlimeDispatch` to catch this `-1` and
"		"	return to original config-dispatching flow.
"		return -1
"	endif
"endfunction
" <<<<<<< For plugin skywind3000/vim-terminal-helper && jpalardy/vim-slime <<<<<<<
