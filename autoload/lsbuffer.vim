
let s:bufnr = 0
" if !exists('g:lsbuffer_ignores')
"     let g:lsbuffer_ignores = ['^\.']
" endif

function! s:savelinenr(path, next)
    if empty(a:next)
        return
    endif
    let b:lslinenrs[substitute(simplify(a:path), '/\+$', '', '')] = fnamemodify(a:next, ':s?.\zs/\+$??:t')
endfunction

function! lsbuffer#newcwd(p)
    if &ft isnot 'lsbuffer'
        return
    endif
    let path = substitute(a:p, '/\+$', '', '')
    let cwd = get(b:, 'cwd', getcwd())
    call s:savelinenr(cwd, getline('.'))
    let b:cwd = path =~ '^\/' ? path : simplify(cwd..'/'..path)
    call s:savelinenr(b:cwd, cwd)
endfunction

function! lsbuffer#togglePattern(pat)
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

function! lsbuffer#toggleHidden()
    call lsbuffer#togglePattern('^\.')
endfunction

function! s:delete(fname) abort
    if confirm(printf('Delete file %s?', fnameescape(a:fname)), "&No\n&Yes") isnot 2
        return
    endif
    if isdirectory(a:fname)
        call delete(a:fname, 'd')
        if isdirectory(a:fname)
            if confirm(printf('%s is a non-empty directory. Are you sure you want to delete?!', fnameescape(a:fname)), "&No\n&Yes") isnot 2
                return
            endif
            call delete(a:fname, 'rf')
        endif
    elseif !empty(glob(a:fname))
        call delete(a:fname)
    else
        echohl ErrorMsg
        echon 'No file: '..fnameescape(a:fname)
        echohl NONE
    endif
endfunction

function! s:deleteOp(type)
    echo range(line(a:type is# 'x' ? "'<" : "'["), line(a:type is# 'x' ? "'>" : "']"))
    for line in getline(line(a:type is# 'x' ? "'<" : "'["), line(a:type is# 'x' ? "'>" : "']"))
        call s:delete(fnamemodify(simplify(b:cwd..'/'..line), ':p'))
    endfor
    call lsbuffer#ls()
endfunction

function! s:touch(p)
    call writefile([], fnamemodify(simplify(a:p =~ '^\/' ? a:p : (get(b:, 'cwd') is 0 ? getcwd() : b:cwd)..'/'..a:p), ':p'))
endfunction

function s:mkdir(p)
    call mkdir(fnamemodify(simplify(a:p =~ '^\/' ? a:p : (get(b:, 'cwd') is 0 ? getcwd() : b:cwd)..'/'..a:p), ':p'), 'p')
endfunction

function! s:addmaps()
    if get(g:, 'no_plugin_maps') || get(b:, 'no_plugin_maps')
        return
    endif
    nnoremap <buffer> <nowait> <silent> <cr> :call lsbuffer#open(v:false)<cr>
    nnoremap <buffer> <nowait> <silent> l :call lsbuffer#open(v:false)<cr>
    nnoremap <buffer> <nowait> <silent> v :call lsbuffer#open(v:true, 'vertical')<cr>
    nnoremap <buffer> <nowait> <silent> s :call lsbuffer#open()<cr>
    nnoremap <buffer> <nowait> <silent> h :call lsbuffer#newcwd('..')<bar>call lsbuffer#ls()<cr>
    nnoremap <buffer> <nowait> <silent> r :call lsbuffer#ls()<cr>
    nnoremap <buffer> <nowait> <silent> d :set opfunc=<sid>deleteOp<cr>g@
    xnoremap <buffer> <nowait> <silent> d :call <sid>deleteOp('x')<cr>
    nmap     <buffer> <nowait> <silent> dd Vd
    nnoremap <buffer> <nowait> <silent> Z :call <sid>savelinenr(b:cwd, getline('.'))<bar>call lsbuffer#toggleHidden()<bar>call lsbuffer#ls()<cr>
    nnoremap <buffer> <nowait>          c :Cd<space>
    nnoremap <buffer> <nowait>          t :Touch<space>
    nnoremap <buffer> <nowait>          D :Mkdir<space>
    nnoremap <buffer> <nowait>          f :FilterToggle<space>
    command! -buffer -nargs=1 -complete=dir  -bar Cd call lsbuffer#newcwd(<q-args>)<bar>call lsbuffer#ls()
    command! -buffer -nargs=1 -complete=file -bar Touch call <sid>touch(<q-args>)<bar>call lsbuffer#ls()
    command! -buffer -nargs=1 -complete=file -bar Mkdir call <sid>mkdir(<q-args>)<bar>call lsbuffer#ls()
    command! -buffer -nargs=1                     FilterToggle call lsbuffer#togglePattern(<q-args>)<bar>call lsbuffer#ls()
endfunction

function! lsbuffer#new(split=v:true, mods='', count=0, cwd='') abort
    execute join(split(a:mods) + ['noswapfile', a:split ? 'keepalt new' : 'enew'])
    if a:count && a:count <= s:bufnr
        execute 'buffer LsBuffer'..s:bufnr
    else
        let b:lslinenrs = {}
        let b:lsbufnr = s:bufnr
        let b:lsbuffer_ignores = ['^\.']
        let s:bufnr += 1
        execute 'file LsBuffer'..s:bufnr
        setlocal bt=nofile ft=lsbuffer noswf nobk
        silent doautocmd User LsBufferNewPre
        call s:addmaps()
    endif
    call lsbuffer#newcwd(empty(a:cwd) ? getcwd() : a:cwd)
    call lsbuffer#ls()
    if !a:count
        silent doautocmd User LsBufferNew
    endif
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

function! lsbuffer#ls() abort
    setlocal noro ma
    silent 0put=map(readdirex(b:cwd, { e -> s:keep(e) }), { _,i -> i.name..(i.type is 'dir' \|\| i.type is 'linkd' ? '/' : '') })
    let line = getline('.')
    let cwd = substitute(get(b:, 'cwd', getcwd()), '/\+$', '', '')
    if !empty(line) && !has_key(b:lslinenrs, cwd)
        call s:savelinenr(cwd, getline('.'))
    endif
    silent +1,$delete
    let linenrcwd = substitute(b:cwd, '/\+$', '', '')
    let lastpath = get(b:lslinenrs, linenrcwd)
    if !empty(lastpath)
        let lnr = search('\V\C\^'..escape(lastpath, '\')..'\>', 'ncw')
    else
        let lnr = 1
    endif
    call setpos('.', [0, lnr, 1, 1])
    normal! zz
    setlocal ro noma
endfunction

function! lsbuffer#open(split=v:true, mods='') abort
    " a:sp -> 'e': edit, 'v': vert sp, '': sp
    call s:savelinenr(b:cwd, getline('.'))
    let line = getline('.')
    if line =~ '\/$'
        if a:split
            call lsbuffer#new(a:split, a:mods, b:cwd..'/'..line)
        else
            let b:cwd .= '/'..line
            call lsbuffer#ls()
        endif
    else
        execute join(split(a:mods) + [a:split ? 'split ' : 'edit '])..fnamemodify(simplify(b:cwd..'/'..line), ':p:~:.')
    endif
endfunction

function! lsbuffer#last()
    " TODO: save last lsbufnr in w:, t:, and g: variables, then find first in
    " the order w:, t:, then g: and open in this function
endfunction
