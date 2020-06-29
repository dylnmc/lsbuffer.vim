" lsbuffer plugin
" AUTHOR: Dylan McClure <dylnnmc at gmail>
" DATE:   28 Jun 2020


" :Ls/:Lsnew commands
"
" +--example----------+--desctipion---------------------------------------+
" | :above vert Lsnew | open new lsbuffer in vertical split on left       |
" | :2Ls              | open LsBuffer2 in current window                  |
" | :Lsnew Downloads  | open new split lsbuffer in directory ./Downloads/ |
" +-------------------+---------------------------------------------------+
command! -count -nargs=? -complete=file Ls    call lsbuffer#new(v:false, <q-mods>, <count>, get([<f-args>], 0, ''))
command! -count -nargs=? -complete=file Lsnew call lsbuffer#new(v:true,  <q-mods>, <count>, get([<f-args>], 0, ''))

if get(g:, 'no_plugin_maps') || get(g:, 'no_lsbuffer_maps')
    " respect g:no_plugin_maps and g:no_lsbuffer_maps
    finish
endif

function! s:warn(...)
    " consistent warning only if g:lsbuffer_verbosity > 0
    "
    " +--arg--+--description ------------+
    " | a:000 | list of messages to echo |
    " +-------+--------------------------+
    if !get(g:, 'lsbuffer_verbosity')
        return
    endif
    echohl WarningMsg
    echom 'Warning (LsBuffer):' join(a:000)
    echohl NONE
endfunction

if hasmapto('Ls') || hasmapto('Lsnew')
    call s:warn('Already mapped :Ls or :Lsnew')
    finish
endif

function! s:addmap(mode, special, lhs, rhs)
    " map a:lhs to a:rhs with a:special mods in a:mode
   "
    " +--arg------+--description------+--examples-------------+
    " | a:mode    | mode to map       | 'n', 'nnore'          |
    " | a:special | special arguments | '<silent>, '<nowait>' |
    " | a:lhs     | LHS               | '<leader>ls'          |
    " | a:rhs     | RHS               | ':Lsnew'              |
    " +-----------+-------------------+-----------------------+
    "
    " eg, :call s:addmap('n', '<silent>', '<leader>ls', ':Lsnew')
    let mode0 = a:mode[0]
    let map = mapcheck(a:lhs, mode0)
    if !empty(map) && map isnot? '<nop>'
        call s:warn('Conflicting map LHS:', a:lhs)
        return
    endif
    execute join([a:mode..'map', a:special, a:lhs, a:rhs])
endfunction

" default mappings
call s:addmap('n', '<silent>', '<leader>ls', ':<c-u>Ls<cr>')
call s:addmap('n', '<silent>', '<leader>lS', ':<c-u>Lsnew<cr>')
call s:addmap('n', '<silent>', '<leader>lv', ':<c-u>aboveleft vertical Lsnew<cr>')
call s:addmap('n', '<silent>', '<leader>lV', ':<c-u>belowright vertical Lsnew<cr>')
call s:addmap('n', '<silent>', '<leader>ll', ':call lsbuffer#last()<cr>')
call s:addmap('n', '<silent>', '<leader>lL', ':call lsbuffer#last(v:true)<cr>')

