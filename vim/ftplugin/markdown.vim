"
"----------------------------------------------------------
"   Name: markdown.vim
"   Author: xyy15926
"   Created: 2018-05-20 16:30:37
"   Updated: 2023-10-18 17:46:54
"   Description: settings especially for markdown
"----------------------------------------------------------

if exists("b:md_ftplugin")
	finish
endif
" packadd vim\-markdown
" colorscheme gruvbox
let b:md_ftplugin = 1
if ! exists("b:lang")
	" let b:lang = input("about what lang?")
	let b:lang = "python"
endif
set noexpandtab

" select last title marked with `===`
onoremap <buffer> ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>
" select last title marked with `===`
onoremap <buffer> ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rg_vk0"<cr>

" convert code-block to list
" nnoremap <buffer> <localleader>cc ^hi-<esc>lli`<esc>f：i`<esc>
" list all tiltes marked with `#`
" Note: `:dlist` also functioned well with `:set define`
nnoremap <buffer> <localleader>ul :<c-u>ilist /^#\{1,6\}[ \t]\+<cr>
" Move to next or previous title marked with `##`
nnoremap <buffer> <localleader>mn :<c-u>/^##\+<cr>
nnoremap <buffer> <localleader>mp :<c-u>?^##\+<cr>
nnoremap <buffer> <localleader>uc ^i```<ESC>"=b:lang<C-M>po```<ESC>O

" Insert code block with `b:lang`, which stores the language-type
inoremap <buffer> <localleader>uc ```<ESC>"=b:lang<C-M>po```<ESC>O
" Insert latex block
" inoremap <buffer> <localleader>xm $$\mathcal{<c-m>}$$<esc>O
" inoremap <buffer> <localleader>xal \begin{align*}<c-m>\end{align*}<esc>O
" inoremap <buffer> <localleader>xar \begin{array}{l}<c-m>\end{array}<esc>O
" inoremap <buffer> <localleader>xi $\mathcal{}$<esc>hi

iabbrev <buffer> >- > -
iabbrev <buffer> [] [ ]
