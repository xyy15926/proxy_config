"----------------------------------------------------------
"   Name: cpp.vim
"   Author: xyy15926
"   Created: 2022-11-15 11:47:03
"   Updated: 2022-11-15 11:47:03
"   Description:
"----------------------------------------------------------

if exists("b:cpp_ftplugin")
	finish
endif
let b:cpp_ftplugin = 1

" >>>>>>> For plugin skywind3000/asyncrun >>>>>>>
function! BuildCpp()
	if filereadable( getcwd() . "/Makefile" ) || filereadable( getcwd() . "/makefile" )
		execute 'AsyncRun -once -mode=quickfix -pos=right -cols=70 -focus=0 -hidden=1 -cwd="$(VIM_ROOT)" make build'
	else
		execute 'AsyncRun -once -mode=quickfix -pos=right -cols=70 -focus=0 -hidden=1 clang -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)'
	endif
endfunction
function! RunCpp()
	if filereadable( getcwd() . "/Makefile" ) || filereadable( getcwd() . "/makefile" )
		execute 'AsyncRun -once -mode=quickfix -cwd="$(VIM_ROOT)" make run'
	else
		execute 'AsyncRun -once -mode=quickfix -cwd="$(VIM_FILEDIR)"  "$(VIM_FILEDIR)/$(VIM_FILENOEXT)"'
	endif
endfunction
function! TestCpp()
	if filereadable( getcwd() . "/Cargo.toml" )
		execute 'AsyncRun -once -mode=quickfix -cwd="$(VIM_ROOT)" make test'
	endif
endfunction
nnoremap <buffer> <localleader>xb :call BuildCpp()
nnoremap <buffer> <localleader>xr :call RunCpp()
nnoremap <buffer> <localleader>xt :call TestCpp()
" <<<<<<< For plugin skywind3000/asyncrun <<<<<<<
