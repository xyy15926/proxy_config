"
"----------------------------------------------------------
"   Name: markdown.vim
"   Author: xyy15926
"   Created: 2018-05-20 16:30:37
"   Updated: 2021-12-09 22:24:40
"   Description: settings especially for markdown
"----------------------------------------------------------

if exists("b:md_ftplugin")
	finish
endif
packadd vim\-markdown
" colorscheme gruvbox
let b:md_ftplugin = 1
if ! exists("b:lang")
	let b:lang = input("about what lang?")
endif
inoremap <buffer> <localleader>cb ```<esc>"=b:lang<c-m>po```<esc>O
	"ask user what language is this md-file about, so to
	"input code block easier

onoremap <buffer> ih :<c-u>execute"normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>
	"select last title marked with `===`
onoremap <buffer> ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rg_vk0"<cr>
	"select last title marked with `===`, with `===`
nnoremap <buffer> <localleader>cc ^hi-<esc>lli`<esc>f：i`<esc>
	"convert code-block to list
nnoremap <buffer> <localleader>lt :<c-u>ilist /^#\{1,6\}[ \t]\+<cr>
	"list all tiltes marked with `#`
	"`:dlist` also functioned well with `:set define`
nnoremap <buffer> <localleader>nt :<c-u>/^##\+<cr>
nnoremap <buffer> <localleader>pt :<c-u>?^##\+<cr>
	"find next/previous title
inoremap <buffer> <localleader>xm $$\mathcal{<c-m>}$$<esc>O
inoremap <buffer> <localleader>xal \begin{align*}<c-m>\end{align*}<esc>O
inoremap <buffer> <localleader>xar \begin{array}{l}<c-m>\end{array}<esc>O
inoremap <buffer> <localleader>xi $\mathcal{}$<esc>hi
	"to input latex easier

iabbrev <buffer> >- > -
	"shortcuts for quoted list
iabbrev <buffer> [] [ ]
	"easiser to input todo list
