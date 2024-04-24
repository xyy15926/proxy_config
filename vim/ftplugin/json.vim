" ---------------------------------------------------------
"   Name: json.vim
"   Author: xyy15926
"   Created: 2022-11-24 10:04:18
"   Updated: 2022-11-24 10:04:18
"   Description:
" ---------------------------------------------------------
"
if exists("b:py_ftplugin")
	finish
endif
let b:json_ftplugin = 1
"
" For convinience, this command is redefined in vimrc, as this command is
" meaningless.
command! -range Jsonf :execute '<line1>,<line2> !python -c "import json,sys,collections,re; sys.stdout.write(json.dumps(json.load(sys.stdin, object_pairs_hook=collections.OrderedDict), indent=2, ensure_ascii=False))"'
set shiftwidth=2
