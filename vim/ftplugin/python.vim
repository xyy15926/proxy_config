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
let b:private_project_root = ""

" Move to next or previous section
" nnoremap <buffer> <localleader>mn :<C-u>/^#\ %%\+<CR>
" nnoremap <buffer> <localleader>mp :<C-u>?^#\ %%\+<CR>
iabbrev <buffer> #%- 
			\# %% ------------------------------------------------------------------------<CR>
			\#						* * * *  * * * *<CR>
			\# ---------------------------------------------------------------------------

" >>>>>>> For plugin jpalardy/vim-slime >>>>>>>
" packadd vim\-slime
if $TERM_PROGRAM ==# 'tmux'
	let g:slime_target = 'tmux'
else
	let g:slime_target = 'vimterminal'
endif
let g:slime_vimterminal_config={
	\ "term_name": "ipython",
	\ "term_cols": 70,
	\ "vertical": 2,
	\ "norestore": 1
	\ }
let g:slime_vimterminal_cmd='pixi run ipython --no-autoindent'
let b:slime_cell_delimiter='^#\ %%'
" nnoremap <buffer> <localleader>sm <Plug>SlimeSendCell:<C-U>/^#\ %%\+<CR>
" let g:which_key_map.s.m = "send-cell-and-move"
" <<<<<<< For plugin jpalardy/vim-slime <<<<<<<

function! SetRoot()
	let root_flags = ['.root', '.svn', '.git', '.hg', '.project', 'Makefile']
	let abspath = expand("%:p")
	let paths = split(abspath, "/")

	let cur_pos = 2
	while cur_pos <= len(paths)
		for rf in root_flags
			let cur_dir = "/" . join(paths[:-cur_pos], "/")
			" echo cur_dir . '/' . rf
			if !empty(glob(cur_dir . '/' . rf ))
				let b:private_project_root = cur_dir
				break
			endif
		endfor
		if !empty(b:private_project_root)
			break
		endif
		let cur_pos += 1
	endwhile
endfunction
call SetRoot()

" >>>>>>> For plugin skywind3000/asyncrun >>>>>>>
function! TestPython()
	let abspath = expand("%:p")
	let paths = split(abspath, "/")
	let filename = paths[-1]

	let run_mode = 'AsyncRun -once -mode=quickfix -cwd="$(VIM_ROOT) '
	let pymode = ''
	if !empty(b:private_project_root)
		if !empty(glob(b:private_project_root . '/' . '.pixi'))
			let pymode = 'pixi run '
		endif

		if filename[0:4] ==# "test_"
			execute run_mode . pymode . 'pytest ' . abspath
		else
			let cur_pos = 2
			let root_hier = len(split(b:private_project_root, "/"))
			while cur_pos + root_hier <= len(paths)
				let modname = join(paths[-cur_pos: -2], "/")
				let testfile = b:private_project_root . "/tests/" . modname . "/test_" . filename
				echo testfile
				if filereadable(testfile)
					execute run_mode . pymode . 'pytest ' . testfile
				endif
				let cur_pos += 1
			endwhile
		endif
	endif
endfunction
function! BuildPython()
	let run_mode = 'AsyncRun -once -mode=quickfix -cwd="$(VIM_ROOT) '
	let pymode = ''
	if !empty(b:private_project_root)
		if !empty(glob(b:private_project_root . '/' . '.pixi'))
			let pymode = 'pixi run '
		endif
		execute run_mode . pymode . 'python -m build'
	endif
endfunction
function! RunPython()
	let abspath = expand("%:p")
	let paths = split(abspath, "/")
	let filename = paths[-1]

	let run_mode = 'AsyncRun -once -mode=term -pos=right -cols=70 -focus=0 -hidden=1 -cwd="$(VIM_ROOT) '
	let pymode = ''
	if !empty(b:private_project_root)
		if !empty(glob(b:private_project_root . '/' . '.pixi'))
			let pymode = 'pixi run '
		endif
		execute run_mode . pymode . 'python "$(VIM_FILEDIR)/$(VIM_FILENAME)"'
	endif
endfunction
nnoremap <buffer> <localleader>xb :call BuildPython()<CR>
nnoremap <buffer> <localleader>xt :call TestPython()<CR>
nnoremap <buffer> <localleader>xr :call RunPython()<CR>
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
