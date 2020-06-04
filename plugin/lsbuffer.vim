
if !get(g:, 'no_plugin_maps') && !get(g:, 'no_lsbuffer_maps')
    if empty(maparg('<leader>ls'))
        nnoremap <silent> <leader>ls :call lsbuffer#new('')<cr>
    endif
    if empty(maparg('<leader>lS'))
        nnoremap <silent> <leader>lS :call lsbuffer#new('e')<cr>
    endif
    if empty(maparg('<leader>ll'))
        nnoremap <silent> <leader>ll :call lsbuffer#last('')<cr>
    endif
    if empty(maparg('<leader>lL'))
        nnoremap <silent> <leader>lL :call lsbuffer#last('e')<cr>
    endif
endif

