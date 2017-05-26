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
    let dummy = system('rm -rf "' . $HOME . '/_viminfo"')
    let dummy = system('rm -rf "' . $HOME . '/.viminfo"')
    let dummy = system('rm -rf "' . $HOME . '/.vim_cache"')
endfunction

" diff vimrc
function! ZF_VimrcDiff()
    redraw!
    echo 'updating...'
    let tmp_path = $HOME . '/.vim_cache/_zf_vimrc_tmp_'
    let dummy = system('rm -rf "' . tmp_path . '"')
    let dummy = system('git clone --depth=1 ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    execute 'edit ' . tmp_path . '/' . g:ZFVimrcUtil_vimrc_file
    setlocal buftype=nofile
    let bufnr1 = bufnr('%')
    call ZF_VimrcEdit()
    let bufnr2 = bufnr('%')
    execute ':call ZF_DiffBuffer(' . bufnr1 . ',' . bufnr2 . ')'
    let dummy = system('rm -rf "' . tmp_path . '"')
endfunction

" update vimrc
function! ZF_VimrcUpdate()
    echo 'Confirm update?'
    echo '  (y)es'
    echo '  (n)o'
    echo '  (a)lso update plugins'
    echo '  (f)orce update all plugins'
    let confirm=nr2char(getchar())
    if confirm!='y' && confirm!='a' && confirm!='f'
        redraw!
        echo 'update canceled'
        return
    endif

    if confirm=='f'
        redraw!
        echo 'cleaning old plugins...'
        let dummy = system('rm -rf "' . $HOME . '/.vim"')
    endif

    redraw!
    echo 'updating...'
    let tmp_path = $HOME . '/.vim_cache/_zf_vimrc_tmp_'
    let dummy = system('rm -rf "' . tmp_path . '"')
    let dummy = system('git clone --depth=1 ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    let dummy = system('cp "' . tmp_path . '/' . g:ZFVimrcUtil_vimrc_file . '" "' . $HOME . '/' . g:ZFVimrcUtil_vimrc_file . '"')
    let dummy = system('rm -rf "' . tmp_path . '"')
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
    let dummy = system('rm -rf "' . tmp_path . '"')
    let dummy = system('git clone --depth=1 ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
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

