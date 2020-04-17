" my personal vim utilities
" for https://github.com/ZSaberLv0/zf_vimrc.vim
" Author:  ZSaberLv0 <http://zsaber.com/>

let g:ZFVimrcUtil_loaded=1

" ============================================================
" config
if !exists('g:ZFVimrcUtil_cachePath')
    if exists('g:zf_vim_cache_path')
        let g:ZFVimrcUtil_cachePath=g:zf_vim_cache_path
    else
        let g:ZFVimrcUtil_cachePath=$HOME . '/.vim_cache'
    endif
endif

if !exists('g:ZFVimrcUtil_PluginUpdateCmd')
    let g:ZFVimrcUtil_PluginUpdateCmd='PlugUpdate'
endif

if !exists('g:ZFVimrcUtil_PluginCleanCmd')
    let g:ZFVimrcUtil_PluginCleanCmd='PlugClean!'
endif

if !exists('g:ZFVimrcUtil_updateCallback')
    let g:ZFVimrcUtil_updateCallback={}
endif

if !exists('g:ZFVimrcUtil_AutoUpdateInterval')
    let g:ZFVimrcUtil_AutoUpdateInterval=2592000
endif

if !exists('g:ZFVimrcUtil_AutoUpdateConfirm')
    let g:ZFVimrcUtil_AutoUpdateConfirm=1
endif

if !exists('g:ZFVimrcUtil_AutoUpdateIntervalFile')
    let g:ZFVimrcUtil_AutoUpdateIntervalFile=g:ZFVimrcUtil_cachePath . '/ZFVimrcLastUpdate'
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
" functions
command! -nargs=0 ZFPlugUpdate :call ZF_VimrcUpdate('a')
command! -nargs=0 ZFPlugClean :execute ':silent! ' . g:ZFVimrcUtil_PluginCleanCmd

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
    if has('viminfo')
        set viminfo=
    endif
    call s:rm($HOME . '/_viminf*')
    call s:rm($HOME . '/.viminf*')
    call s:rm($HOME . '/_viminfo')
    call s:rm($HOME . '/.viminfo')
    call s:rm(g:ZFVimrcUtil_cachePath)
endfunction

" diff vimrc
function! ZF_VimrcDiff()
    redraw!
    echo '[ZFVimrcUtil] updating...'
    let tmp_path = g:ZFVimrcUtil_cachePath . '/_zf_vimrc_tmp_'
    call s:rm(tmp_path)
    call system('git clone --depth=1 ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    execute 'edit ' . tmp_path . '/' . g:ZFVimrcUtil_vimrc_file
    setlocal buftype=nofile
    let bufnr1 = bufnr('%')
    call ZF_VimrcEdit()
    let bufnr2 = bufnr('%')
    execute ':call s:ZF_VimrcDiff(' . bufnr1 . ',' . bufnr2 . ')'
    call s:rm(tmp_path)
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
function! ZF_VimrcUpdate(...)
    let confirm = get(a:, 1, '')
    if empty(confirm)
        echo '[ZFVimrcUtil] Confirm update? (note: local zf_vimrc.vim would be overrided)'
        echo '  (y)es'
        echo '  (n)o'
        echo '  (a)lso update plugins'
        echo '  (f)orce update all plugins (remove all local plugins before update)'
        let confirm=nr2char(getchar())
    endif
    if confirm!='y' && confirm!='a' && confirm!='f' && confirm!='u'
        redraw!
        echo '[ZFVimrcUtil] update canceled'
        return
    endif

    call ZF_VimrcAutoUpdateMarkFinish()

    if confirm=='f'
        redraw!
        echo '[ZFVimrcUtil] cleaning old plugins...'
        call s:rm($HOME . '/.vim')
    endif

    redraw!
    echo '[ZFVimrcUtil] updating...'
    let tmp_path = g:ZFVimrcUtil_cachePath . '/_zf_vimrc_tmp_'
    call s:rm(tmp_path)
    call system('git clone --depth=1 ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    call s:cp(tmp_path . '/' . g:ZFVimrcUtil_vimrc_file, $HOME . '/' . g:ZFVimrcUtil_vimrc_file)
    call s:rm(tmp_path)

    for module in keys(g:ZFVimrcUtil_updateCallback)
        redraw!
        echo '[ZFVimrcUtil] updating ' . module . '...'
        execute 'call ' g:ZFVimrcUtil_updateCallback[module] . '()'
    endfor

    if confirm=='y'
        call ZF_VimrcEdit()
        return
    endif

    call ZF_VimrcLoad()

    if confirm=='u'
        if !empty(g:ZFVimrcUtil_PluginCleanCmd)
            execute ':silent! ' . g:ZFVimrcUtil_PluginCleanCmd
        endif
    endif

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

    if exists('g:zf_git_user_token') && !empty(g:zf_git_user_token)
        let git_password = g:zf_git_user_token
    else
        call inputsave()
        let git_password = inputsecret('Enter password: ')
        if strlen(git_password) <= 1
            redraw!
            echo '[ZFVimrcUtil] update canceled'
            return
        endif
        call inputrestore()
    endif

    redraw!
    echo '[ZFVimrcUtil] updating...'
    let tmp_path = g:ZFVimrcUtil_cachePath . '/_zf_vimrc_tmp_'
    call s:rm(tmp_path)
    call system('git clone --depth=1 ' . g:ZFVimrcUtil_git_repo . ' "' . tmp_path . '"')
    call s:cp($HOME . '/' . g:ZFVimrcUtil_vimrc_file, tmp_path . '/' . g:ZFVimrcUtil_vimrc_file)
    call system('cd "' . tmp_path . '" && git config user.email "' . g:zf_git_user_email . '"')
    call system('cd "' . tmp_path . '" && git config user.name "' . g:zf_git_user_name . '"')
    call system('cd "' . tmp_path . '" && git commit -a -m "update vimrc"')
    redraw!
    echo '[ZFVimrcUtil] pushing...'
    let pushResult = system('cd "' . tmp_path . '" && git push ' . g:ZFVimrcUtil_git_repo_head . g:zf_git_user_name . ':' . git_password . '@' . g:ZFVimrcUtil_git_repo_tail . ' HEAD')
    redraw!
    " strip password
    let pushResult = substitute(pushResult, ':[^:]*@', '@', 'g')
    echo pushResult
    call s:rm(tmp_path)
endfunction

function! s:cp(from, to)
    if(has('win32') || has('win64') || has('win95') || has('win16'))
        call system('copy /y "' . substitute(a:from, '/', '\\', 'g') . '" "' . substitute(a:to, '/', '\\', 'g') . '"')
    else
        call system('cp "' . a:from . '" "' . a:to . '"')
    endif
endfunction

function! s:rm(f)
    if(has('win32') || has('win64') || has('win95') || has('win16'))
        call system('del /f/s/q "' . substitute(a:f, '/', '\\', 'g') . '"')
        call system('rmdir /s/q "' . substitute(a:f, '/', '\\', 'g') . '"')
    else
        call system('rm -rf "' . a:f. '"')
    endif
endfunction

" ============================================================
" auto update
function! ZF_VimrcAutoUpdateMarkFinish()
    silent! call mkdir(fnamemodify(g:ZFVimrcUtil_AutoUpdateIntervalFile, ':p:h'), 'p', '0777')
    silent! call writefile([localtime()], g:ZFVimrcUtil_AutoUpdateIntervalFile)
endfunction
function! ZF_VimrcAutoUpdate(...)
    if g:ZFVimrcUtil_AutoUpdateInterval <= 0
        return
    endif
    if filereadable(g:ZFVimrcUtil_AutoUpdateIntervalFile)
        let lastUpdate = join(readfile(g:ZFVimrcUtil_AutoUpdateIntervalFile), '')
        let lastUpdate = substitute(lastUpdate, '[ \t]', '', 'g')
    else
        let lastUpdate = 0
    endif
    let curTime = localtime()
    if curTime < lastUpdate + g:ZFVimrcUtil_AutoUpdateInterval
        return
    endif
    call ZF_VimrcAutoUpdateMarkFinish()

    if g:ZFVimrcUtil_AutoUpdateConfirm
        redraw!
        let confirm=confirm("[ZFVimrcUtil] you have not update for a long time, update now?\n", "&Yes\n&No")
        if confirm!=1
            redraw!
            echo '[ZFVimrcUtil] update canceled'
            return
        endif
    endif

    call ZF_VimrcUpdate('u')
endfunction
function! s:ZF_VimrcAutoUpdateCheck()
    if has('timers')
        call timer_start(200, 'ZF_VimrcAutoUpdate')
        return
    endif
    call ZF_VimrcAutoUpdate()
endfunction
augroup ZF_VimrcAutoUpdate_augroup
    autocmd!
    if exists('v:vim_did_enter') && v:vim_did_enter
        call s:ZF_VimrcAutoUpdateCheck()
    else
        autocmd VimEnter * call s:ZF_VimrcAutoUpdateCheck()
    endif
augroup END

