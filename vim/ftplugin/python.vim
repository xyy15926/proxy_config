" >>>>>>> For plugin jpalardy/vim-slime >>>>>>>
if exists("b:py_ftplugin")
	finish
endif
let b:py_ftplugin = 1
packadd vim\-slime
let g:slime_vimterminal_config={"term_name": "ipython", "term_cols": 55, "vertical": 1, "norestore": 1}
let g:slime_vimterminal_cmd="ipython --no-autoindent"
let g:slime_cell_delimiter="# %%"
" <<<<<<< For plugin jpalardy/vim-slime <<<<<<<
