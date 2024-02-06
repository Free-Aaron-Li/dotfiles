"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author:
"        aaron.li
" Sections:
"        -> Basic
"        -> Keybindings
"        -> Plugins
"        -> Themes
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Basic
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Encoding format 
set encoding=UTF-8
set fileencodings=UTF-8

""" Relative line numbers and relative ranges
set number
set relativenumber

""" Highlight and Guides
" Highlight the row
set cursorline
" Search highlight
set nohlsearch
" Display left icon sign column
set signcolumn="yes"
" Display right color reference column
set colorcolumn=120
" Turn on syntax highlighting.
syntax on

""" Indent
" Four spaces equals one Tab.
set tabstop=4
set softtabstop=4
" << >> indent
set shiftround
set shiftwidth=4

""" Aligned
" New line aligns current line
set autoindent
set smartindent

""" Search
" Search is case-insensitive unless it contains uppercase.
set ignorecase
set smartcase
" Enter Search Sync
set incsearch

""" Autoload
" Automatic loading when files are modified by external programs
set autoread

""" Page
" Command line height
set cmdheight=2
" No folding
"set wrap
" Cursor can jump to the next line when it is at the end of a line
set whichwrap=h,l,b,s,<,>,[,]
" Allows hiding modified buffers
" By default, Vim doesn't let you hide a buffer (i.e. have a buffer that isn't
" shown in any window) that has unsaved changes. This is to prevent you from "
" forgetting about unsaved changes and then quitting e.g. via `:qa!`. We find
" hidden buffers helpful enough to disable this protection. See `:help hidden`
" for more information on this.
set hidden
" Mouse support
set mouse+=a
" Prohibiting backup creation
set nobackup
set nowritebackup
set noswapfile
" Auto update time
set updatetime=500
" Wait for keyboard combo time
set timeoutlen=200
" Cursor is a vertical line in insert mode 
set gcr=n-v-c:ver25-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor

""" Split window appearance time
" Below and right
set splitbelow
set splitright

""" Autocomplete Not Autoselected
set completeopt="menu,menuone,noselect,noinsert"

""" Completion enhancement
" Completion enhancement
set wildmenu
" Complete the maximum number of rows displayed
set pumheight=10
" Show tabline
set showtabline=2
" Don't show vim mode prompt
set noshowmode
" Disable the default Vim startup message.
set shortmess+=I
" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2
" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start
" Disable audible bell 
" because it's annoying.
set noerrorbells visualbell t_vb=


""" Vi compatibility
" Vim is based on Vi. Setting `nocompatible` switches from the default
" Vi-compatibility mode and enables useful Vim functionality. This
" configuration option turns out not to be necessary for the file named
" '~/.vimrc', because Vim automatically enters nocompatible mode if that file
" is present. But we're including it here just in case this config file is
" loaded some other way (e.g. saved as `foo`, and then Vim started with
" `vim -u foo`).
set nocompatible





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Keybindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" prompt
" map is recursive 
" noremap is non-recursive
""" Unbind
" Unbind some useless/annoying default key bindings.
" 'Q' in normal mode enters Ex mode. You almost never want this.
nmap Q <Nop> 

""" Leader
let mapleader = "\<space>"
""" ESC
inoremap <M-j> <esc>
nnoremap <M-j> <esc>
vnoremap <M-j> <esc>





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PLugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Nord
call plug#begin('~/.vim/plugged')
Plug 'nordtheme/vim'
call plug#end()




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Themes
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Dracula
"if v:version < 802
"    packadd! dracula
"endif
"syntax enable
"colorscheme dracula

""" Nord
colorscheme nord
