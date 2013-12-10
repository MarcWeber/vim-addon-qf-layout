if !exists('g:aztec') | let g:aztec = {} | endif | let s:c = g:aztec

" order of formatters to be used when cycling
let s:c.quickfix_formatters = get(s:c, 'quickfix_formatters', ['NOP', 'aztec#DefaultFormatter', 'aztec#FormatterNoFilename', 'aztec#Reset'])

let s:c.lhs_cycle = get(s:c, 'lhs_cycle', '<buffer> \v')

" don't add more than 60 spaces to filenames when aligning
" If there are a couple of very long files only having too many spaces would
" be annoying
let s:c.file_name_align_max_width = 60

let s:c.hold_cursor = get(s:c, 'hold_cursor', 1)

" whenever the quickfix window gets opened, enhance it:
auto filetype qf call aztec#Quickfix()

if s:c.hold_cursor
  " auto cursormoved * if (&filetype is 'qf') | call aztec#Interface_hold_on('^.\{-}|.\{-}| .\zs.*') | end
endif
