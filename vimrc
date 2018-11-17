set shell=/bin/zsh
syntax on
" line numbers
set number
"linen number distance to border
set numberwidth=3
" number relative to cursor
set relativenumber

" show a visual line under the cursor's current line
set cursorline

" show the matching part of the pair for [] {} and ()
set showmatch

" enable all Python syntax highlighting features
let python_highlight_all = 1

" COLERSCHEME
"colorscheme spacegray


set nocompatible              " be iMproved, required
filetype off                  " required
filetype plugin on

" install vim-plug if it is not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Vim-Plug related commands
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes


" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" statusbar theme
Plug 'itchyny/lightline.vim'
if !has('gui_running')
  set t_Co=256
endif
set laststatus=2
Plug 'https://github.com/tpope/vim-eunuch'
" Not working??
Plug 'https://github.com/tpope/vim-surround'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Linting
Plug 'w0rp/ale'
" Git features
Plug 'airblade/vim-gitgutter'
" Color scheme
"Plug 'ajh17/Spacegray.vim'
" Julia syntax
Plug 'JuliaEditorSupport/julia-vim'
" Commenter
Plug 'scrooloose/nerdcommenter'
" autoclose of tags
Plug 'raimondi/delimitmate'
" autocompletion
Plug 'Valloric/YouCompleteMe'
" Python higligh (NOT WORKING)??
Plug 'https://github.com/vim-python/python-syntax'
let python_highlight_all = 1
" syntax highlighitng
Plug 'https://github.com/vim-syntastic/syntastic'
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" Set working DIR to project root
Plug 'airblade/vim-rooter'
" typescript linting
Plug 'leafgarland/typescript-vim'




" Initialize plugin system
call plug#end()

" -----KEYBINDS-------
map ; :Files<CR>
let mapleader = ','
