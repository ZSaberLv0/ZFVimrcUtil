" my personal vim utilities
" for https://github.com/ZSaberLv0/zf_vimrc.vim
" Author:  ZSaberLv0 <http://zsaber.com/>

let g:ZFVimrcUtil_loaded=1

" ============================================================
" config
if !exists('g:ZFVimrcUtil_PluginUpdateCmd')
    let g:ZFVimrcUtil_PluginUpdateCmd='PlugUpdate'
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
    execute 'silent! source $HOME/' . g:ZFVimrcUtil_vimrc_file
endfunction
function! ZF_VimrcEdit()
    execute 'edit $HOME/' . g:ZFVimrcUtil_vimrc_file
endfunction
function! ZF_VimrcEditOrg()
    edit $MYVIMRC
endfunction

" cleanup vim
function! ZF_VimClean()
    set viminfo=
    call system('rm -rf "' . $HOME . '/_viminf*"')
    call system('rm -rf "' . $HOME . '/.viminf*"')
    call delete($HOME . '/_viminfo')
    call delete($HOME . '/.viminfo')
    call delete($HOME . '/.vim_cache', 'rf')
endfunction

" diff vimrc
function! ZF_VimrcDiff()
    redraw!
    echo 'updating...'
    let tmp_path = $HOME . '/.vim_cache/_zf_vimrc_tmp_'
    call delete(tmp_path, 'rf')
    call system('git clone --depth=1 ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    execute 'edit ' . tmp_path . '/' . g:ZFVimrcUtil_vimrc_file
    setlocal buftype=nofile
    let bufnr1 = bufnr('%')
    call ZF_VimrcEdit()
    let bufnr2 = bufnr('%')
    execute ':call s:ZF_VimrcDiff(' . bufnr1 . ',' . bufnr2 . ')'
    call delete(tmp_path, 'rf')
endfunction
function! s:ZF_VimrcDiff(b0, b1)
    if has('gui')
        set lines=9999 columns=9999
    endif
    if(has('win32') || has('win64') || has('win95') || has('win16'))
        simalt ~x
    endif
    vsplit
    execute "normal! \<c-w>h"
    execute "b" . a:b0
    diffthis
    execute "normal! \<c-w>l"
    execute "b" . a:b1
    diffthis
    normal! <c-w>=
endfunction

" update vimrc
function! ZF_VimrcUpdate()
    echo 'Confirm update? (note: local zf_vimrc.vim would be overrided)'
    echo '  (y)es'
    echo '  (n)o'
    echo '  (a)lso update plugins'
    echo '  (f)orce update all plugins (remove all local plugins before update)'
    let confirm=nr2char(getchar())
    if confirm!='y' && confirm!='a' && confirm!='f'
        redraw!
        echo 'update canceled'
        return
    endif

    if confirm=='f'
        redraw!
        echo 'cleaning old plugins...'
        call delete($HOME . '/.vim', 'rf')
    endif

    redraw!
    echo 'updating...'
    let tmp_path = $HOME . '/.vim_cache/_zf_vimrc_tmp_'
    call delete(tmp_path, 'rf')
    call system('git clone --depth=1 ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    call s:cp(tmp_path . '/' . g:ZFVimrcUtil_vimrc_file, $HOME . '/' . g:ZFVimrcUtil_vimrc_file)
    call delete(tmp_path, 'rf')
    if confirm!='a' && confirm!='f'
        call ZF_VimrcEdit()
        return
    endif

    call ZF_VimrcLoad()
    execute ':silent! ' . g:ZFVimrcUtil_PluginUpdateCmd
endfunction

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
    call delete(tmp_path, 'rf')
    call system('git clone --depth=1 ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    call s:cp($HOME . '/' . g:ZFVimrcUtil_vimrc_file, tmp_path . '/' . g:ZFVimrcUtil_vimrc_file)
    call system('git -C "' . tmp_path . '" config user.email "' . g:zf_git_user_email . '"')
    call system('git -C "' . tmp_path . '" config user.name "' . g:zf_git_user_name . '"')
    call system('git -C "' . tmp_path . '" config push.default "simple"')
    call system('git -C "' . tmp_path . '" commit -a -m "update vimrc"')
    redraw!
    echo 'pushing...'
    let pushResult = system('git -C "' . tmp_path . '" push ' . g:ZFVimrcUtil_git_repo_head . g:zf_git_user_name . ':' . git_password . '@' . g:ZFVimrcUtil_git_repo_tail)
    redraw!
    " strip password
    let pushResult = substitute(pushResult, ':[^:]*@', '@', 'g')
    echo pushResult
    call delete(tmp_path, 'rf')
endfunction

function! s:cp(from, to)
    if(has('win32') || has('win64') || has('win95') || has('win16'))
        call system('copy /y "' . substitute(a:from, '/', '\\', 'g') . '" "' . substitute(a:to, '/', '\\', 'g') . '"')
    else
        call system('cp "' . a:from . '" "' . a:to . '"')
    endif
endfunction

