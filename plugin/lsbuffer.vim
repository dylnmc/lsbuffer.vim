
let s:T = exists('v:true')  ? v:true  : 1
let s:F = exists('v:false') ? v:false : 0

function! s:mapadd(typ, special, map, rhs)
    let map = mapcheck(a:map, a:typ[0])
    if !(empty(map) || map is? '<nop>')
        return s:T
    endif
    execute join([a:typ..'map', a:special, a:map, a:rhs])
    return s:F
endfunction

command! Ls    call lsbuffer#new(v:false, <q-mods>)
command! Lsnew call lsbuffer#new(v:true,  <q-mods>)

if !get(g:, 'no_plugin_maps') && !get(g:, 'no_lsbuffer_maps')
    call s:mapadd('nnore', '<silent>', '<leader>ls', ":Lsnew<cr>")
    call s:mapadd('nnore', '<silent>', '<leader>lv', ":vertical Lsnew<cr>")
    call s:mapadd('nnore', '<silent>', '<leader>lS', ":Ls<cr>")
    " call s:mapadd('nnore', '<silent>', '<leader>ll', ":call lsbuffer#last('')<cr>")
    " call s:mapadd('nnore', '<silent>', '<leader>lL', ":call lsbuffer#last('e')<cr>")
endif

