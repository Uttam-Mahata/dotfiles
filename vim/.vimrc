" ============================================================
" Plugins (vim-plug)
" ============================================================
call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}   " VS Code-style autocomplete/LSP
" --- Neovim (LazyVim) parity ---
Plug 'ghifarit53/tokyonight-vim'                  " tokyonight (storm), same theme as Neovim
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'                           " Telescope equivalent (files, grep, buffers)
Plug 'tpope/vim-fugitive'                         " :Git, :Gdiffsplit
Plug 'tpope/vim-surround'                         " nvim-surround bindings (ys, cs, ds)
Plug 'tpope/vim-commentary'                       " gc / gcc comments (built in to Neovim 0.10+)
Plug 'christoomey/vim-tmux-navigator'             " <C-h/j/k/l> across vim and tmux panes
Plug 'airblade/vim-gitgutter'                     " git signs in the gutter
Plug 'vim-airline/vim-airline'                    " statusline (lualine equivalent)
Plug 'liuchengxu/vim-which-key'                   " leader-key hints (which-key equivalent)
Plug 'tpope/vim-repeat'                           " enable '.' repeat for surround & commentary
Plug 'tpope/vim-rhubarb'                          " GitHub extension for fugitive (:GBrowse)
Plug 'sheerun/vim-polyglot'                       " modern syntax highlighting for 100+ languages
Plug 'Yggdroot/indentLine'                        " vertical indentation guides
call plug#end()

" ============================================================
" General behavior
" ============================================================
set nocompatible
set clipboard=unnamedplus      " y/d/p use the system clipboard
syntax on
filetype plugin indent on

set number                     " plain absolute line numbers
set showcmd

" netrw sets its own local cursorline on its buffer regardless of the
" global setting above — turn it off there too
augroup netrw_no_cursorline
    autocmd!
    autocmd FileType netrw setlocal nocursorline
augroup END
set wildmenu                   " visual command-line completion
set scrolloff=8                " keep 8 lines visible above/below cursor
set mouse=                     " mouse off, same as the Neovim config
set hidden                     " allow switching buffers without saving

set ignorecase smartcase       " case-insensitive unless a capital is typed
set incsearch hlsearch

set expandtab
set tabstop=4 shiftwidth=4 softtabstop=4
set autoindent smartindent

set undofile                   " persistent undo across sessions
set undodir=~/.vim/undodir
if !isdirectory($HOME."/.vim/undodir")
    call mkdir($HOME."/.vim/undodir", "p")
endif

let mapleader = " "

" ============================================================
" Save / quit
" ============================================================
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader>Q :qa!<CR>

" ============================================================
" Clear search highlight
" ============================================================
nnoremap <leader>/ :nohlsearch<CR>

" ============================================================
" Window / split management
" ============================================================
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <leader>= <C-w>=       " equalize split sizes
nnoremap <leader>sc :close<CR>

" ============================================================
" Buffers and tabs
" ============================================================
nnoremap <leader>c :bdelete<CR>
nnoremap <leader>C :bdelete!<CR>
nnoremap <leader>bd :bdelete<CR>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>to :tabonly<CR>

" ============================================================
" Move lines up/down
" ============================================================
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" ============================================================
" Better visual-mode indenting (keeps selection after indent)
" ============================================================
vnoremap < <gv
vnoremap > >gv

" ============================================================
" Keep cursor centered while scrolling / searching
" ============================================================
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

" PageDown/PageUp: half-page scroll instead of full-page overshoot on short files
nnoremap <PageDown> <C-d>zz
nnoremap <PageUp> <C-u>zz

" ============================================================
" Move by visual line, not physical line, when wrapped
" ============================================================
nnoremap j gj
nnoremap k gk

" ============================================================
" Quick edit / reload vimrc
" ============================================================
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>sv2 :source $MYVIMRC<CR>

" ============================================================
" Toggle common settings
" ============================================================
nnoremap <leader>n :set relativenumber!<CR>
nnoremap <leader>sp :set spell! spelllang=en_us<CR>
nnoremap <leader>pp :set paste!<CR>

" ============================================================
" Yank/paste conveniences
" ============================================================
nnoremap Y y$                   " Y yanks to end of line, like D and C
xnoremap p "_dP                 " paste over selection without losing register
nnoremap <leader>d "_d           " delete without overwriting register

" ============================================================
" Trim trailing whitespace
" ============================================================
nnoremap <leader>tw :%s/\s\+$//e<CR>

" ============================================================
" Terminal mode (:terminal) navigation
" ============================================================
tnoremap <Esc> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l

" ============================================================
" coc.nvim — VS Code-style autocomplete / LSP
" ============================================================
let g:coc_global_extensions = [
    \ 'coc-json',
    \ 'coc-snippets',
    \ 'coc-java',
    \ 'coc-go',
    \ 'coc-rust-analyzer',
    \ 'coc-tsserver',
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-yaml',
    \ 'coc-markdownlint'
    \ ]

" IndentLine configuration
let g:indentLine_char = '│'
let g:indentLine_fileTypeExclude = ['help', 'netrw', 'coc-explorer']

set updatetime=300
set shortmess+=c
set signcolumn=yes

" Tab/Shift-Tab to cycle suggestions, Enter to confirm
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Ctrl-Space to force-trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" gd/gy/gi/gr — go to definition/type/implementation/references
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" K — show documentation/hover for symbol under cursor
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" leader+rn — rename symbol; leader+ca — code action / quick fix
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>ca <Plug>(coc-codeaction-cursor)
nmap <leader>qf <Plug>(coc-fix-current)

" [g / ]g — jump to previous/next diagnostic (error/warning)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" ============================================================
" Neovim / LazyVim parity
" ============================================================
" Defaults Neovim has and Vim 9 lacks
set autoread
set backspace=indent,eol,start
set display=lastline
set encoding=utf-8
set laststatus=2
set ruler
set ttimeout ttimeoutlen=50
set nrformats-=octal
set sidescroll=1
set smarttab
set tabpagemax=50
set viminfo^=!
set history=10000
set complete-=i
set formatoptions+=j

" Look and feel (Neovim: tokyonight-storm, termguicolors, splits right/below)
set termguicolors
set splitright splitbelow
set nocursorline
set list listchars=tab:>\ ,trail:.,nbsp:+
set fillchars=vert:\|
set timeoutlen=400             " leader-key hints appear quickly, as in LazyVim
let g:tokyonight_style = 'storm'
let g:tokyonight_enable_italic = 1
silent! colorscheme tokyonight
let g:airline_theme = 'tokyonight'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 0
let g:gitgutter_map_keys = 0

" <Esc> clears search highlight (LazyVim)
nnoremap <silent> <Esc> :nohlsearch<CR><Esc>

" Telescope-style finders (LazyVim: <leader>ff, <leader>fg, <leader>fb, <leader>fr, <leader>fh)
nnoremap <leader>ff :Files<CR>
nnoremap <leader><space> :Files<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>/ :Rg<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>, :Buffers<CR>
nnoremap <leader>fr :History<CR>
nnoremap <leader>fh :Helptags<CR>
nnoremap <leader>fc :Commands<CR>
nnoremap <leader>fk :Maps<CR>
nnoremap <leader>gc :Commits<CR>
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gb :Git blame<CR>
" file explorer (LazyVim: <leader>e)
nnoremap <leader>e :Lexplore<CR>
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25
" buffers (LazyVim: <S-h>/<S-l>, [b ]b, <leader>bd)
nnoremap <S-h> :bprevious<CR>
nnoremap <S-l> :bnext<CR>
" hunks and diagnostics like LazyVim: ]h [h for git hunks
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <leader>gh <Plug>(GitGutterPreviewHunk)
" which-key
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
" restore cursor position when reopening a file (LazyVim)
augroup restore_cursor
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END
