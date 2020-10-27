"" General
set autowrite
set clipboard^=unnamedplus
set expandtab shiftwidth=2
set hidden
set ignorecase
set linebreak
set nobackup
set noshowmode
set noswapfile
set nowritebackup
set number relativenumber
set shortmess+=c
set showbreak=+++
set showmatch
set signcolumn=yes
set smartcase
set smartindent
set softtabstop=2
set textwidth=120
set undolevels=1000
set updatetime=300
set visualbell

let mapleader=";"
let g:mapleader=";"
let g:python3_host_prog="~/.asdf/shims/python3"

"" Plugins
call plug#begin('~/.local/share/nvim/plugged')

  Plug 'arcticicestudio/nord-vim'
  Plug 'brglng/vim-im-select', { 'on': '<Plug>ImSelectEnable' }
  Plug 'editorconfig/editorconfig-vim'
  Plug 'itchyny/lightline.vim'
  Plug 'jiangmiao/auto-pairs'
  Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary' }
  Plug 'liuchengxu/vista.vim'
  Plug 'neoclide/coc-git', { 'do': 'yarn install --frozen-lockfile' }
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
  Plug 'sheerun/vim-polyglot'
  Plug 'tmux-plugins/vim-tmux-focus-events'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-sensible'
  Plug 'vn-ki/coc-clap'
  Plug 'voldikss/vim-floaterm'

call plug#end()

"" keybindings
nnoremap <silent> <leader>w :w<CR>

nnoremap <space> <C-w>w
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
inoremap <M-h> <Esc><C-w>h
inoremap <M-j> <Esc><C-w>j
inoremap <M-k> <Esc><C-w>k
inoremap <M-l> <Esc><C-w>l
tnoremap <M-h> <C-\><C-n><C-w>h
tnoremap <M-j> <C-\><C-n><C-w>j
tnoremap <M-k> <C-\><C-n><C-w>k
tnoremap <M-l> <C-\><C-n><C-w>l

"" nord-vim
colorscheme nord

"" vim-im-select
let g:im_select_default = 'com.apple.keylayout.US'

"" vim-clap
nmap <silent> <C-p> :Clap files ++finder=fd --type f --hidden --exclude '.git/'<CR>
nmap <silent> <Leader>f :Clap grep2<CR>
nmap <silent> <Leader>b :Clap buffers<CR>
nmap <silent> <Leader>c :Clap command_history<CR>
nmap <silent> <Leader>l :Clap lines<CR>
nmap <silent> <Leader>T :Clap tags<CR>
nmap <silent> sf :Clap filer<CR>
let g:clap_theme = 'nord'

"" coc-clap
nnoremap <silent> <space>a :Clap coc_diagnostics<CR>
nnoremap <silent> <space>e :Clap coc_extensions<CR>
nnoremap <silent> <space>c :Clap coc_commands<CR>
nnoremap <silent> <space>o :Clap coc_outline<CR>
nnoremap <silent> <space>s :Clap coc_symbols<CR>

"" Vista.vim
let g:vista_default_executive = 'coc'

"" vim-floaterm
nnoremap <silent> <Leader>t :FloatermToggle<CR>
tnoremap <silent> <Leader>t <C-\><C-n>:FloatermToggle<CR>
nnoremap <silent> <Leader>g :FloatermNew --name=lg --autoclose=2 lazygit<CR>

"" lightline.vim
function! CocGitStatus()
  return get(g:, 'coc_git_status', '')
endfunction

function! FilenameWithPath()
  return expand('%')
endfunction

let g:lightline = {
  \ 'colorscheme': 'nord',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'readonly', 'filename', 'modified', 'gitstatus', 'cocstatus', ] ]
  \ },
  \ 'component_function': {
  \   'cocstatus': 'coc#status',
  \   'gitstatus': 'CocGitStatus',
  \   'filename': 'FilenameWithPath',
  \ },
  \ }

"" coc.nvim
let g:coc_global_extensions = [
  \ 'coc-angular',
  \ 'coc-eslint',
  \ 'coc-go',
  \ 'coc-java',
  \ 'coc-json',
  \ 'coc-metals',
  \ 'coc-python',
  \ 'coc-rls',
  \ 'coc-rome',
  \ 'coc-tsserver',
  \ 'coc-vetur',
  \ 'coc-vimlsp',
  \ 'coc-yaml',
  \ ]
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
" Formatting selected code.
xmap <leader>F  <Plug>(coc-format-selected)
nmap <leader>F  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
