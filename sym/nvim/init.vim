" vim:ft=vim ts=2 sw=2 sts=2 fdm=marker foldenable et fenc=utf-8

" ====================================================================
" 
" This file contains my NeoVim configuration.
"
" Use zo to open the folds, zc to close them and zn to disable them.
"
" ====================================================================

set nocompatible
let mapleader = ","

" {{{ PLUGINS

" {{{ PLUG SETUP

let s:root_plug = expand("~/.local/share/nvim/plugged")
call plug#begin(s:root_plug)

" }}}

" {{{ AIRLINE

Plug 'vim-airline/vim-airline'

" ALE support
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#error_symbol = '✖:'
let g:airline#extensions#warning_symbol = '⚠:'

" Enable top tabline
let g:airline#extensions#tabline#enabled = 1

" Enable powerline fonts
let g:airline_powerline_fonts = 1

" }}}

" {{{ ALE (Asynchronous Lint Engine)

Plug 'w0rp/ale'

let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'
let g:ale_lint_on_text_changed = 'never'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%severity%] %linter% : %s'

" Error navigation
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" }}}

" {{{ CtrlP

" NOTE: The main reason why this plugin is installed is to be used by vim-go's
" GoDeclrs(Dir).
Plug 'ctrlpvim/ctrlp.vim'

let g:ctrlp_map = ''

" }}}

" {{{ NERDTREE

Plug 'scrooloose/nerdtree'

nnoremap <leader>d :NERDTreeToggle<cr>

" Files to ignore
let NERDTreeIgnore = [
  \ '\~$',
  \ '\.pyc$',
  \ '^\.DS_Store$',
  \ '^node_module$',
  \ '^.ropeproject$',
  \ '^__pycache__$'
\]

" Close vim if NERDTree is the only opened window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Show hidden files by default
let NERDTreeShowHidden = 1

" Allow NERDTree to change session root
let g:NERDTreeChDirMode = 2

" }}}

" {{{ VIM-GO

Plug 'fatih/vim-go'

let g:go_highlight_build_constraints = 1
let g:go_hightlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1

let g:go_auto_type_info = 1

" Highlight instances of the variable under the cursor
let g:go_auto_sameids = 1

" Auto import dependencies
let g:go_fmt_command = "goimports"

" }}}

" {{{ VIM CODE DARK

Plug 'tomasiser/vim-code-dark'

" }}}

" {{{ PLUG TEARDOWN

call plug#end()
silent! helptags ALL

" }}}

" }}}

" {{{ BASIC SETTINGS

filetype plugin indent on

" Modelines
set modelines=2
set modeline

" "Fuzzy" :find command
set path+=**

" Set the Python binaries neovim is using
let g:python_host_prog = "/usr/bin/python2"
let g:python3_host_prog = "/usr/bin/python3"

" Search
set ignorecase smartcase
set grepprg=grep\ -IrsnH

" Buffers
set history=500
set hidden

syntax enable
set encoding=utf8
set ffs=unix,dos,mac

" Enable 256 color palette in Gnome Terminal
if $COLORTERM == 'gnome-terminal'
  set t_Co=256
endif

try
  " Colorscheme with airline support
  colorscheme codedark
  let g:airline_theme = 'codedark'
catch
endtry

" Delete trailing white space on save.
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.txt,*.py,*.sh,*.go,*.c,*.h :call CleanExtraSpaces()
endif

" Don't close window, when deleting a buffer.
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

" }}}

" {{{ USER INTERFACE

set so=7
set wildmenu
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
set ruler
set smartcase
set hlsearch
set incsearch
set showmatch
set mat=2
set lazyredraw
set number relativenumber

" Automatic toggling between number modes (as in vim-numbertoggle).
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END

" No sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" }}}

" {{{ TEXT, TAB AND INDENT

set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set ai
set si
set wrap

" Default linebreak on 500 characters
set lbr
set tw=500

" }}}

" {{{ MOVING AROUND

" Move between windows using Ctrl+(j,k,h,l).
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Tab managing maps.
map <leader>tn :tabnew<cr>
map <leader>to <C-w>T
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext

" Disable highlight.
map <silent> <leader><cr> :noh<cr>

" Toggle between the current and last accessed tab.
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path.
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer.
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behaviour when switching between buffers.
try
    set switchbuf=useopen,usetab,newtab
    set stal=2
catch
endtry

" Return to the last edit position when opening files.
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" }}}

" {{{ STATUS LINE

" Always show the status line.
set laststatus=2

" Format the status line.
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

" }}}

" {{{ REMAPPINGS

" Remap VIM 0 to first non-blank character.
map 0 ^

" Move a line of text using ALT+[jk].
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-j> :m'<-2<cr>`>my`<mzgv`yo`z

" }}}

" {{{ HELPER FUNCTIONS

" Returns true if paste mode is enabled.
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

" }}}

