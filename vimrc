let g:user42 = 'kojwatan'
let g:mail42 = 'kojwatan@student.42tokyo.jp'

"deleteが効かなくなったので設定
set backspace=indent,eol,start

syntax enable
filetype on
filetype plugin on
set clipboard+=unnamed
set nowrap

set number
set ruler
colorscheme default

"表示系
set cursorline
set cursorcolumn
set virtualedit=onemore

"TABの設定
set smartindent
set list listchars=tab:\>\-

inoremap jj <ESC>

nnoremap <C-h> :tabprev<CR>
nnoremap <C-l> :tabnext<CR>
nnoremap <S-h> <C-w>h
nnoremap <S-l> <C-w>l
nnoremap <S-k> <C-w>k
nnoremap <S-j> <C-w>j

let mapleader = " "
nnoremap <C-n> :NERDTreeToggle<CR>

set statusline+=%{expand('%:p:h')}

" プラグイン
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree' " ファイルツリー
Plug 'tpope/vim-fugitive' " Git連携
Plug 'itchyny/lightline.vim' " 軽量ステータスライン
Plug 'jiangmiao/auto-pairs' " 括弧の自動補完
Plug 'tpope/vim-commentary' " 複数行のコメントアウト
Plug 'airblade/vim-gitgutter' " git差分のインライン表示

call plug#end()

" lightlineの設定
set laststatus=2
let g:lightline = {
 \ 'active': {
 \   'left': [ [ 'mode', 'paste' ],
 \             [ 'readonly', 'filename', 'modified' ] ],
 \   'right': [ [ 'lineinfo' ],
 \              [ 'percent' ],
 \              [ 'gitbranch' ] ]
 \ },
 \ 'component_function': {
 \   'gitbranch': 'FugitiveHead'
 \ },
 \ }

" autopairの設定
let g:AutoPairsFlyMode = 1
let g:AutoPairsShortcutToggle = '<M-p>'
