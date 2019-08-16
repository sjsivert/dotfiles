
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
if !has('gui_running')
  set t_Co=256
endif
set laststatus=2

Plug 'https://github.com/tpope/vim-surround'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Linting
Plug 'w0rp/ale'
" Git features
Plug 'airblade/vim-gitgutter'
" Color scheme
Plug 'dracula/vim', { 'as': 'dracula' }
"Plug 'ajh17/Spacegray.vim'
" Julia syntax
" Plug 'JuliaEditorSupport/julia-vim'
" Commenter
Plug 'scrooloose/nerdcommenter'
" autoclose of tags
Plug 'raimondi/delimitmate'
" autocompletion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" python highlighting
Plug 'kh3phr3n/python-syntax'
let python_highlight_all = 1
" Python code formatter
Plug 'Chiel92/vim-autoformat'
" Ranger as filemanager
"Plug 'francoiscabrol/ranger.vim'
Plug 'iberianpig/ranger-explorer.vim'
nnoremap <silent><Leader>c :RangerOpenCurrentDir<CR>
nnoremap <silent><Leader>f :RangerOpenProjectRootDir<CR>

" Initialize plugin system
call plug#end()
