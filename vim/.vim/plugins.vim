
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



" Multiple Plug commands can be written in a single line using | separators
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" statusbar theme
Plug 'itchyny/lightline.vim'

" colorscheme
Plug 'mhartington/oceanic-next'
if !has('gui_running')
  set t_Co=256
endif
set laststatus=2

Plug 'https://github.com/tpope/vim-surround'

" Latex all-in-one package
"Plug 'vim-latex/vim-latex'
" A Vim Plugin for Lively Previewing LaTeX PDF Output
"Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }
" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Git features
Plug 'airblade/vim-gitgutter'
" Commenter
Plug 'scrooloose/nerdcommenter'
" autoclose of tags
Plug 'jiangmiao/auto-pairs'
" autocompletion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" show marks made with m
Plug 'kshenoy/vim-signature'

" MarkDownPreview
Plug 'iamcco/mathjax-support-for-mkdp'
Plug 'iamcco/markdown-preview.vim'

"
""---Higlighting---
" typescript highlighting

" === Javascript Plugins === "
" Typescript syntax highlighting
Plug 'HerringtonDarkholme/yats.vim'

" ReactJS JSX syntax highlighting
Plug 'mxw/vim-jsx'
j
" === Syntax Highlighting === "
" Syntax highlighting for nginx
Plug 'chr4/nginx.vim'

" Syntax highlighting for javascript libraries
Plug 'othree/javascript-libraries-syntax.vim'

" Improved syntax highlighting and indentation
Plug 'othree/yajs.vim'

" python highlighting
Plug 'kh3phr3n/python-syntax'
let python_highlight_all = 1

" Icons
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Kotlin language server
autocmd BufReadPost *.kt setlocal filetype=kotlin

let g:LanguageClient_serverCommands = {
    \ 'kotlin': ["kotlin-language-server"],
    \ }
" Vim-OrgMode. Like Emacs
"Plug '/jceb/vim-orgmode'
" Javascript syntax highlighting and indation
"Plug 'pangloss/vim-javascript'
" highlighting for jsdocs
"let g:javascript_plugin_jsdoc = 1
" Initialize plugin system
call plug#end()
