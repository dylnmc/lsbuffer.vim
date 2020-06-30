" lsbuffer autoload
" AUTHOR: Dylan McClure <dylnmc at gmail>
" DATE:   30 June 2020

let s:bufnr = 0

function! s:simplify(path, end=v:false)
    let path = simplify(substitute(a:path, '^/\{2,}', '/', ''))
    if a:end
        let path = substitute(path,  '.\zs/\+$', '', '')
    else
        let path = substitute(path, '/\{2,}$', '/', '')
    endif
    return path
endfunction

function! s:savelinenr(path, next)
    if empty(a:next)
        return
    endif
    let b:_lsb_lastnames[s:simplify(a:path, v:true)] = fnamemodify(a:next, ':s?.\zs/\+$??:t')
endfunction

function! lsbuffer#newcwd(p, add=v:true) abort
    if &ft isnot 'lsbuffer'
        return
    endif
    let path = expand(a:p)
    let cwd = get(b:, '_lsb_cwd', getcwd())
    call s:savelinenr(cwd, getline('.'))
    if a:add
        if exists('b:_lsb_cwd')
            if !exists('b:_lsb_cwds')
                let b:_lsb_cwds = []
            endif
        endif
        if exists('b:_lsb_cwd')
            call add(b:_lsb_cwds, b:_lsb_cwd)
        endif
    endif
    let b:_lsb_cwd = s:simplify(path =~ '^\/' ? path : cwd..'/'..path, v:true)
    call s:savelinenr(b:_lsb_cwd, cwd)
    let autotype = get(b:, 'lsbuffer_autotype')
    if autotype[:0] is 'g'
        execute 'cd '..b:_lsb_cwd
    elseif autotype[:0] is 'l'
        execute 'lcd '..b:_lsb_cwd
    elseif autotype[:0] is 't'
        execute 'tcd '..b:_lsb_cwd
    endif
endfunction

function! lsbuffer#togglePattern(pat, savlin=v:true)
    if a:savlin
        call s:savelinenr(b:_lsb_cwd, getline('.'))
    endif
    if &ft isnot 'lsbuffer'
        return
    endif
    let ind = index(b:lsbuffer_ignores, a:pat)
    if ind is -1
        call add(b:lsbuffer_ignores, a:pat)
    else
        call remove(b:lsbuffer_ignores, ind)
    endif
endfunction

function! s:delete(fname) abort
    let ename = fnameescape(a:fname)
    if confirm(printf('Delete file %s?', ename), "&No\n&Yes") isnot 2
        return
    endif
    if isdirectory(a:fname)
        call delete(a:fname, 'd')
        if isdirectory(a:fname)
            if confirm(printf('%s is a non-empty directory. Are you sure you want to delete?!', ename), "&No\n&Yes") isnot 2
                return
            endif
            call delete(a:fname, 'rf')
        endif
    elseif !empty(glob(ename))
        call delete(a:fname)
    else
        echohl ErrorMsg
        echon 'No file: '..ename
        echohl NONE
    endif
endfunction

function! s:deleteOp(type) abort
    silent execute 'lcd' b:_lsb_cwd
    for line in getline(line(a:type is# 'x' ? "'<" : "'["), line(a:type is# 'x' ? "'>" : "']"))
        call s:delete(line)
    endfor
    call lsbuffer#ls()
    silent cd -
endfunction

function! s:touch(...) abort
    silent execute 'lcd' b:_lsb_cwd
    for f in a:000
        " WONTFIX:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        " FIXME: this creates new files but doesn't touch preexisting ones
        "      : https://github.com/vim/vim/issues/6287
        " WONTFIX:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        call writefile(0z, f, 'ab')
    endfor
    silent cd -
endfunction

function s:mkdir(...)
    for f in a:000
        call mkdir(s:simplify(f =~ '^\/' ? f : (get(b:, '_lsb_cwd') is 0 ? getcwd() : b:_lsb_cwd)..'/'..f), 'p')
    endfor
endfunction

function! s:addmaps()
    if get(g:, 'no_plugin_maps') || get(b:, 'no_plugin_maps')
        return
    endif
    nnoremap <buffer> <nowait> <silent> <cr> :call lsbuffer#open(v:false)<cr>
    nnoremap <buffer> <nowait> <silent> l :call lsbuffer#open(v:false)<cr>
    nnoremap <buffer> <nowait> <silent> v :call lsbuffer#open(v:true, 'vertical')<cr>
    nnoremap <buffer> <nowait> <silent> u :call lsbuffer#upcwds()<cr>
    nnoremap <buffer> <nowait> <silent> s :call lsbuffer#open()<cr>
    nnoremap <buffer> <nowait> <silent> h :call lsbuffer#newcwd('..')<bar>call lsbuffer#ls()<cr>
    nnoremap <buffer> <nowait> <silent> r :call lsbuffer#ls()<cr>
    nnoremap <buffer> <nowait> <silent> d :set opfunc=<sid>deleteOp<cr>g@
    xnoremap <buffer> <nowait> <silent> d :call <sid>deleteOp('x')<cr>
    nmap     <buffer> <nowait> <silent> dd Vd
    nnoremap <buffer> <nowait> <silent> Z :FilterToggle ^\.<cr>
    nnoremap <buffer> <nowait> <silent> ~ :Cd ~<cr>
    nnoremap <buffer> <nowait>          aa :let b:lsbuffer_autotype = 'g'<bar>echo 'Autochdir enabled Globally'<cr>
    nnoremap <buffer> <nowait>          al :let b:lsbuffer_autotype = 'b'<bar>echo 'Autochdir enabled for Buffer'<cr>
    nnoremap <buffer> <nowait>          at :let b:lsbuffer_autotype = 't'<bar>echo 'Autochdir enabled for Tabpage'<cr>
    nnoremap <buffer> <nowait>          ad :sil! unlet b:lsbuffer_autotype<bar>echo 'Autochdir Disabled'<cr>
    nnoremap <buffer> <nowait>          cc :execute 'cd '..b:_lsb_cwd<bar>echo 'Global pwd set:' b:_lsb_cwd<cr>
    nnoremap <buffer> <nowait>          cl :execute 'lcd '..b:_lsb_cwd<bar>echo 'Local pwd set:' b:_lsb_cwd<cr>
    nnoremap <buffer> <nowait>          ct :execute 'tcd '..b:_lsb_cwd<bar>echo 'Tabpage pwd set:' b:_lsb_cwd<cr>
    nnoremap <buffer> <nowait>          R :call lsbuffer#resolve()<cr>
    nnoremap <buffer> <nowait>          gR :call lsbuffer#resolve(v:true)<cr>
    nnoremap <buffer> <nowait>          p :echo b:_lsb_cwd<cr>
    nnoremap <buffer> <nowait>          C :Cd<space>
    nnoremap <buffer> <nowait>          T :Touch<space>
    nnoremap <buffer> <nowait>          D :Mkdir<space>
    nnoremap <buffer> <nowait>          F :FilterToggle<space>
    command! -buffer -nargs=1 -complete=dir  -bar Cd call lsbuffer#newcwd(<q-args>)<bar>call lsbuffer#ls()
    command! -buffer -nargs=+ -complete=file -bar Touch call <sid>touch(<f-args>)<bar>call lsbuffer#ls()
    command! -buffer -nargs=+ -complete=file -bar Mkdir call <sid>mkdir(<f-args>)<bar>call lsbuffer#ls()
    command! -buffer -nargs=1                     FilterToggle call lsbuffer#togglePattern(<q-args>)<bar>call lsbuffer#ls()
endfunction

function! lsbuffer#new(split=v:true, mods='', count=0, cwd='') abort
    let cnt = v:count ? v:count : a:count
    execute join(split(a:mods) + ['noswapfile', a:split ? 'keepalt new' : 'enew'])
    if cnt && cnt <= s:bufnr
        execute 'buffer LsBuffer'..cnt
    else
        let b:_lsb_lastnames = {}
        let b:lsbuffer_ignores = ['^\.']
        let s:bufnr += 1
        let b:_lsb_bufnr = s:bufnr
        execute 'file LsBuffer'..s:bufnr
        setlocal bt=nofile ft=lsbuffer noswf nobk
        silent doautocmd User LsBufferNewPre
        call s:addmaps()
        silent doautocmd User LsBufferNew
    endif
    call lsbuffer#newcwd(empty(a:cwd) ? getcwd() : a:cwd)
    call lsbuffer#ls()
endfunction

function! s:keep(item) abort
    let name = a:item.name
    if a:item.type is 'dir' || a:item.type is 'linkd'
        let name .= '/'
    endif
    let ignores = get(b:, 'lsbuffer_ignores', []) + get(g:, 'lsbuffer_ignores', [])
    for ig in ignores
        if name =~ ig
            return v:false
        endif
    endfor
    return v:true
endfunction

function! s:buildname(item)
    let out = a:item.name
    let type = a:item.type
    if type is 'dir' || type is 'linkd'
        let out ..= '/'
    endif
    if type is 'link' || type is 'linkd'
        let out ..= "\t\n -> "..resolve(a:item.name)
    endif
    return out
endfunction

function! lsbuffer#ls() abort
    setlocal noro ma
    let line = getline('.')
    let cwd = substitute(get(b:, '_lsb_cwd', getcwd()), '/\+$', '', '')
    if !empty(line) && !has_key(b:_lsb_lastnames, cwd)
        call s:savelinenr(cwd, getline('.'))
    endif
    silent %delete
    call setline(1, map(readdirex(b:_lsb_cwd, { e -> s:keep(e) }), { _,item -> s:buildname(item) }))
    let lastpath = get(b:_lsb_lastnames, substitute(b:_lsb_cwd, '/\+$', '', ''))
    if !empty(lastpath)
        let lnr = search('\V\C\^'..escape(lastpath, '\')..'\>', 'ncw')
    else
        let lnr = 1
    endif
    call setpos('.', [0, lnr, 1, 1])
    normal! zz
    setlocal ro noma conceallevel=3 concealcursor=nvic
    let w:_lsb_last = b:_lsb_bufnr
    let t:_lsb_last = b:_lsb_bufnr
    let g:_lsb_last = b:_lsb_bufnr
endfunction

function! lsbuffer#open(split=v:true, mods='') abort
    let line = substitute(getline('.'), '\t\?\%x00.*', '', '')
    if empty(line)
        return
    endif
    call s:savelinenr(b:_lsb_cwd, line)
    if line =~ '\/$'
        if a:split
            call lsbuffer#new(a:split, a:mods, 0, b:_lsb_cwd..'/'..line)
        else
            if exists('b:_lsb_cwd')
                if !exists('b:_lsb_cwds')
                    let b:_lsb_cwds = []
                endif
            endif
            if exists('b:_lsb_cwd')
                call add(b:_lsb_cwds, b:_lsb_cwd)
            endif
            let b:_lsb_cwd .= '/'..line
            call lsbuffer#ls()
        endif
    else
        execute join(split(a:mods) + [a:split ? 'split ' : 'edit '])..fnamemodify(s:simplify(b:_lsb_cwd..'/'..line), ':p:~:.')
    endif
endfunction

function! lsbuffer#upcwds()
    if !exists('b:_lsb_cwds') || empty(b:_lsb_cwds)
        return
    endif
    call lsbuffer#newcwd(remove(b:_lsb_cwds, -1), v:false)
    call lsbuffer#ls()
endfunction

function! lsbuffer#resolve(split=v:false, mods='')
    let line = resolve(b:_lsb_cwd..'/'..substitute(getline('.'), '\t\?\%x00.*', '', ''))
    call s:savelinenr(b:_lsb_cwd, line)
    if line =~ '\/$'
        if a:split
            call lsbuffer#new(a:split, a:mods, 0, line)
        else
            if exists('b:_lsb_cwd')
                if !exists('b:_lsb_cwds')
                    let b:_lsb_cwds = []
                endif
            endif
            if exists('b:_lsb_cwd')
                call add(b:_lsb_cwds, b:_lsb_cwd)
            endif
            let b:_lsb_cwd = line
            call lsbuffer#ls()
        endif
    else
        execute join(split(a:mods) + [a:split ? 'split ' : 'edit '])..fnamemodify(s:simplify(line), ':p:~:.')
    endif
endfunction

function! lsbuffer#last(split=v:false, mods='')
    call lsbuffer#new(a:split, a:mods, get(w:, '_lsb_last', get(t:, '_lsb_last', get(g:, '_lsb_last', s:bufnr))))
endfunction

