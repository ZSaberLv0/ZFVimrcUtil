" my personal vim utilities
" for https://github.com/ZSaberLv0/zf_vimrc.vim
" Author:  ZSaberLv0 <http://zsaber.com/>

if exists("g:ZFVimrcUtil_loaded") && g:ZFVimrcUtil_loaded != 1
    finish
endif

" ============================================================
" config
if !exists('g:ZFVimrcUtil_keymap')
    let g:ZFVimrcUtil_keymap=1
endif

if !exists('g:ZFVimrcUtil_vimrc_file')
    let g:ZFVimrcUtil_vimrc_file='zf_vimrc.vim'
endif

if !exists('g:ZFVimrcUtil_git_repo_head')
    let g:ZFVimrcUtil_git_repo_head='https://'
endif

if !exists('g:ZFVimrcUtil_git_repo_tail')
    let g:ZFVimrcUtil_git_repo_tail='github.com/ZSaberLv0/zf_vimrc.vim'
endif

let g:ZFVimrcUtil_git_repo=g:ZFVimrcUtil_git_repo_head . g:ZFVimrcUtil_git_repo_tail

" ============================================================
" edit vimrc
function! ZF_VimrcLoad()
    execute 'source $HOME/' . g:ZFVimrcUtil_vimrc_file
endfunction
function! ZF_VimrcEdit()
    execute 'edit $HOME/' . g:ZFVimrcUtil_vimrc_file
endfunction
function! ZF_VimrcEditOrg()
    edit $MYVIMRC
endfunction
if g:ZFVimrcUtil_keymap == 1
    nnoremap <leader>vimrc :call ZF_VimrcEdit()<cr>
    nnoremap <leader>vimrt :call ZF_VimrcEditOrg()<cr>
endif

" cleanup vim
function! ZF_VimClean()
    set viminfo=
    let dummy = system('rm -rf "' . $HOME . '/_viminfo"')
    let dummy = system('rm -rf "' . $HOME . '/.viminfo"')
    let dummy = system('rm -rf "' . $HOME . '/.vim_cache"')
endfunction
if g:ZFVimrcUtil_keymap == 1
    nnoremap <leader>vimclean :call ZF_VimClean()<cr>
endif

" diff vimrc
function! ZF_VimrcDiff()
    redraw!
    echo 'updating...'
    let tmp_path = $HOME . '/.vim_cache/_zf_vimrc_tmp_'
    let dummy = system('rm -rf "' . tmp_path . '"')
    let dummy = system('git clone ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    execute 'edit ' . tmp_path . '/' . g:ZFVimrcUtil_vimrc_file
    setlocal buftype=nofile
    let bufnr1 = bufnr('%')
    call ZF_VimrcEdit()
    let bufnr2 = bufnr('%')
    execute ':call ZF_DiffBuffer(' . bufnr1 . ',' . bufnr2 . ')'
    let dummy = system('rm -rf "' . tmp_path . '"')
endfunction
if g:ZFVimrcUtil_keymap == 1
    nnoremap <leader>vimrd :call ZF_VimrcDiff()<cr>
endif

" update vimrc
function! ZF_VimrcUpdate()
    echo 'Confirm update?'
    echo '  (y)es'
    echo '  (n)o'
    echo '  (a)lso update plugins'
    let confirm=nr2char(getchar())
    if confirm!='y' && confirm!='a'
        redraw!
        echo 'update canceled'
        return
    endif

    redraw!
    echo 'updating...'
    let tmp_path = $HOME . '/.vim_cache/_zf_vimrc_tmp_'
    let dummy = system('rm -rf "' . tmp_path . '"')
    let dummy = system('git clone ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    let dummy = system('cp "' . tmp_path . '/' . g:ZFVimrcUtil_vimrc_file . '" "' . $HOME . '/' . g:ZFVimrcUtil_vimrc_file . '"')
    let dummy = system('rm -rf "' . tmp_path . '"')
    if confirm=='a'
        call ZF_VimrcLoad()
        execute ':PluginUpdate'
    else
        call ZF_VimrcEdit()
    endif
endfunction
if g:ZFVimrcUtil_keymap == 1
    nnoremap <leader>vimru :call ZF_VimrcUpdate()<cr>
endif

" commit vimrc
function! ZF_VimrcPush()
    if !exists('g:zf_git_user_email')
        echo 'g:zf_git_user_email not set'
    endif
    if !exists('g:zf_git_user_name')
        echo 'g:zf_git_user_name not set'
    endif

    call inputsave()
    let git_password = input('Enter password: ')
    if strlen(git_password) <= 1
        redraw!
        echo 'update canceled'
        return
    endif
    call inputrestore()

    " prevent password from being saved to viminfo
    set viminfo=

    redraw!
    echo 'updating...'
    let tmp_path = $HOME . '/.vim_cache/_zf_vimrc_tmp_'
    let dummy = system('rm -rf "' . tmp_path . '"')
    let dummy = system('git clone ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    let dummy = system('cp "' . $HOME . '/' . g:ZFVimrcUtil_vimrc_file . '" "' . tmp_path . '/' . g:ZFVimrcUtil_vimrc_file . '"')
    let dummy = system('git -C "' . tmp_path . '" config user.email "' . g:zf_git_user_email . '"')
    let dummy = system('git -C "' . tmp_path . '" config user.name "' . g:zf_git_user_name . '"')
    let dummy = system('git -C "' . tmp_path . '" config push.default "simple"')
    let dummy = system('git -C "' . tmp_path . '" commit -a -m "update vimrc"')
    redraw!
    echo 'pushing...'
    let dummy = system('git -C "' . tmp_path . '" push ' . g:ZFVimrcUtil_git_repo_head . g:zf_git_user_name . ':' . git_password . '@' . g:ZFVimrcUtil_git_repo_tail)
    redraw!
    " strip password
    let dummy = substitute(dummy, ':[^:]*@', '@', 'g')
    echo dummy
    let dummy = system('rm -rf "' . tmp_path . '"')
endfunction
if g:ZFVimrcUtil_keymap == 1
    nnoremap <leader>vimrp :call ZF_VimrcPush()<cr>
endif
