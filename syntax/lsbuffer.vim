
if exists('b:current_syntax')
    finish
endif

let b:current_syntax = 'lsbuffer'

syntax match lsbufferDirectory "^.*\/\ze\t\%x00\|^.*\/$"
syntax match lsbufferSymlink "\%(\t\%x00\)\@<= -> .*"
syntax match lsbufferComment "\%x00.*"
syntax match lsbufferConceal "\t\@<=\%x00" conceal

highlight link lsbufferDirectory Directory
highlight link lsbufferComment Comment
highlight link lsbufferExec String
highlight link lsbufferSymlink Include

