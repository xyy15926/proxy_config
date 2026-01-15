" ---------------------------------------------------------
"   Name: rust.vim
"   Author: xyy15926
"   Created: 2023-09-09 13:32:02
"   Updated: 2023-09-09 13:32:02
"   Description:
" ---------------------------------------------------------
"
if exists("b:rust_ftplugin")
	finish
endif
let b:rust_ftplugin = 1
" autocmd BufRead,BufNewFile Cargo.toml,Cargo.lock,*.rs compiler cargo
" autocmd BufRead,BufNewFile Cargo.toml,Cargo.lock,*.rs noremap <buffer> <F9> :make build<CR>
" set makeprg=rustc\ %:S
" set errorformat=%Eerror[E%n]:\ %#%m,%C\ %#-->\ %f:%l:%c

" >>>>>>> For plugin skywind3000/asyncrun >>>>>>>
" Note1:
" Asyncrun will pass output to quickfix line by line, leading content won't be flushed
" entirely immediately, thus the line filtered by `errorformat` will be missed.
" Hence, `-once` is set to provide buffer here.
" Note2:
" So, adding `-slient` flag and `:sleep` to wait for quickfix to update also
" works.
" Note3:
" `:cwindow` won't reopen quickfix if opened, a.k.a. content won't be
" refreshed.
function! BuildRust()
	let run_mode = 'AsyncRun -once -mode=term -pos=right -cols=70 -focus=0 -hidden=1 -cwd="$(VIM_ROOT)" '
	if filereadable( getcwd() . "/Cargo.toml" )
		execute run_mode . 'RUST_BACKTRACE=1 cargo build'
	else
		execute run_mode . 'rustc "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)"'
	endif
	" sleep 100m
	" copen
endfunction
function! RunRust()
	let abspath = expand("%:p")
	let paths = split(abspath, "/")
	let filename = paths[-1]
	let binname = filename[:-4]
	let par_dir = paths[-2]

	let run_mode = 'AsyncRun -once -mode=term -pos=right -cols=70 -focus=0 -hidden=1 -cwd="$(VIM_ROOT)" '
	if filereadable( getcwd() . "/Cargo.toml" )
		if filename ==# "main.rs"
			execute run_mode . '-cwd="$(VIM_ROOT)" cargo run'
		elseif par_dir ==# "bin"
			execute run_mode . '-cwd="$(VIM_ROOT)" cargo run --bin ' . binname
		elseif par_dir ==# "examples"
			execute run_mode . '-cwd="$(VIM_ROOT)" cargo run --example ' . binname
		endif
	else
		execute run_mode '-cwd="$(VIM_FILEDIR)" "$(VIM_FILEDIR)/$(VIM_FILENOEXT)"'
	endif
endfunction
function! TestRust()
	let abspath = expand("%:p")
	let paths = split(abspath, "/")
	let filename = paths[-1]
	let binname = filename[:-4]
	let par_dir = paths[-2]

	let run_mode = 'AsyncRun -once -mode=quickfix -cwd="$(VIM_ROOT)" '
	if filereadable( getcwd() . "/Cargo.toml" )
		if par_dir == "bin"
			execute run_mode . '-cwd=$(VIM_ROOT) cargo test --bin ' . binname
		elseif par_dir == "tests"
			execute run_mode . '-cwd=$(VIM_ROOT) cargo test --test ' . binname
		else
			execute run_mode . '-cwd=$(VIM_ROOT) cargo test ' . binname . '::tests'
		endif
	endif
endfunction
nnoremap <buffer> <localleader>xb :call BuildRust()<CR>
nnoremap <buffer> <localleader>xt :call TestRust()<CR>
nnoremap <buffer> <localleader>xr :call RunRust()<CR>
nnoremap <buffer> <localleader>xe :!cargo run<CR>
" <<<<<<< For plugin skywind3000/asyncrun <<<<<<<
