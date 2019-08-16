

" make backspace behave in a sane manner
set backspace=indent,eol,start

" Scrolling before cursor reach end of screen
set scrolloff=10

" use indents of 4 spaces
 set shiftwidth=4

" tabs are tabs
 set noexpandtab

" an indentation every four columns
 set tabstop=4

" let backspace delete indent
 set softtabstop=4

 " enable auto indentation
 set autoindent

 " remove trailing whitespaces and ^M chars
 augroup ws
   au!
     autocmd FileType c,cpp,java,php,js,json,css,scss,sass,py,rb,coffee,python,twig,xml,yml
     autocmd BufWritePre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))
augroup end


" Yaml files spesific settings
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab


" maintain undo history between sessions
 set undofile
 set undodir=~/.vim/undo
 set noswapfile

" -----KEYBINDS-------
map ; :Files<CR>
map f; :Ag<CR>
let mapleader = "," " change <Leader> key from \ to ,
