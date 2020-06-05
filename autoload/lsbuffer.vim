
let s:bufnr = 0
let s:ignores = ['^\.']

function! s:lsShow(name) abort
    let ignores = s:ignores + get(b:, 'lsbuffer_ignores', []) + get(g:, 'lsbuffer_ignroes', [])
    for ig in ignores
        if a:name =~ ig
            return v:true
        endif
    endfor
    return v:false
endfunction

function! s:newCwd(p)
    let cwd = get(b:, 'cwd', getcwd())
    let b:lslinenrs[substitute(cwd, '\/\+$', '', '')] = line('.')
    let b:cwd = simplify(a:p =~ '^\/' ? a:p : cwd..'/'..a:p)
endfunction

function! s:toggleHidden()
    let ind = index(s:ignores, '^\.')
    if ind is -1
        call add(s:ignores, '^\.')
    else
        call remove(s:ignores, ind)
    endif
    call lsbuffer#ls()
endfunction

function! s:delete(lnr) abort
    let fname = fnamemodify(b:cwd..'/'..getline('.'), ':p')
    if confirm(printf('Delete file %s?', fnameescape(fname)), "&No\n&Yes") isnot 2
        return
    endif
    if isdirectory(fname)
        call delete(fname, 'd')
        if isdirectory(fname)
            if confirm(printf('%s is a non-empty directory. Are you sure you want to delete?!', fnameescape(fname)), "&No\n&Yes") isnot 2
                return
            endif
            call delete(fname, 'rf')
        endif
    elseif !empty(glob(fname))
        call delete(fname)
    else
        echohl ErrorMsg
        echon 'No file: '..fnameescape(fname)
        echohl NONE
    endif
endfunction

function! s:deleteOp(type)
    for lnr in range(line(a:type is# 'x' ? "'<" : "'["), line(a:type is# 'x' ? "'>" : "']"))
        call s:delete(lnr)
    endfor
    call lsbuffer#ls()
endfunction

function! s:touch(p)
    call writefile([], fnamemodify(simplify(a:p =~ '^\/' ? a:p : (get(b:, 'cwd') is 0 ? getcwd() : b:cwd)..'/'..a:p), ':p'))
endfunction

function s:mkdir(p)
    call mkdir(fnamemodify(simplify(a:p =~ '^\/' ? a:p : (get(b:, 'cwd') is 0 ? getcwd() : b:cwd)..'/'..a:p), ':p'), 'p')
endfunction

function! lsbuffer#new(sp, ...) abort
    " a:sp -> 'e': enew, 'v': vnew, '': new
    execute a:sp.'new'
    let b:lslinenrs = {}
    let b:lsbufnr = s:bufnr
    let s:bufnr += 1
    execute 'file LsBuffer'..s:bufnr
    setlocal bt=nofile ft=lsbuffer noswf nobk
    call s:newCwd(a:0 ? a:1 : getcwd())
    call lsbuffer#ls()
    if !get(g:, 'no_plugin_maps') && !get(b:, 'no_plugin_maps')
        nnoremap <buffer> <nowait> <silent> l :call lsbuffer#open('e')<cr>
        nnoremap <buffer> <nowait> <silent> <cr> :call lsbuffer#open('e')<cr>
        nnoremap <buffer> <nowait> <silent> v :call lsbuffer#open('v')<cr>
        nnoremap <buffer> <nowait> <silent> s :call lsbuffer#open('')<cr>
        nnoremap <buffer> <nowait> <silent> h :call <sid>newCwd('..')<bar>call lsbuffer#ls()<cr>
        nnoremap <buffer> <nowait> <silent> r :call lsbuffer#ls()<cr>
        nnoremap <buffer> <nowait> <silent> d :set opfunc=<sid>deleteOp<cr>g@
        xnoremap <buffer> <nowait> <silent> d :call <sid>deleteOp('x')<cr>
        nmap     <buffer> <nowait> <silent> dd Vd
        nnoremap <buffer> <nowait>          c :CD<space>
        nnoremap <buffer> <nowait>          t :TOUCH<space>
        nnoremap <buffer> <nowait>          D :MKDIR<space>
        nnoremap <buffer> <nowait> <silent> z :call <sid>toggleHidden()<cr>

        command! -buffer -nargs=1 -complete=dir  -bar CD :call <sid>newCwd(<q-args>)<bar>call lsbuffer#ls()
        command! -buffer -nargs=1 -complete=file -bar TOUCH :call <sid>touch(<q-args>)<bar>call lsbuffer#ls()
        command! -buffer -nargs=1 -complete=file -bar MKDIR :call <sid>mkdir(<q-args>)<bar>call lsbuffer#ls()
    endif
    silent doautocmd User LsBufferNew
endfunction

function! lsbuffer#ls() abort
    setlocal noro ma 
    silent 1,$d
    silent put=map(readdirex(b:cwd, { e -> !s:lsShow(e.name) }), { _,x -> or(x.type is 'dir', x.type is 'linkd') ? x.name..'/' : x.name })
    silent 1d
    let linenrcwd = substitute(b:cwd, '\/\+$', '', '')
    if has_key(b:lslinenrs, linenrcwd)
        call setpos('.', [0, b:lslinenrs[linenrcwd], 1])
    endif
    setlocal ro noma
endfunction

function! lsbuffer#open(sp) abort
    " a:sp -> 'e': edit, 'v': vert sp, '': sp
    let b:lslinenrs[substitute(b:cwd, '\/\+$', '', '')] = line('.')
    let line = getline('.')
    if line =~ '\/$'
        if a:sp is 'v' || a:sp is ''
            call lsbuffer#new(a:sp, b:cwd..'/'..line)
        else
            let b:cwd .= '/'..line
            call lsbuffer#ls()
        endif
    else
        execute join(a:sp is# 'e' ? 'edit' : a:sp..'split', fnamemodify(simplify(b:cwd..'/'..line), ':p:~:.'))
    endif
endfunction

function! lsbuffer#last()
    " TODO: save last lsbufnr in w:, t:, and g: variables, then find first in
    " the order w:, t:, then g: and open in this function
endfunction
