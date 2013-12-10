if !exists('g:vim_addon_qf_layout') | let g:vim_addon_qf_layout = {} | endif | let s:c = g:vim_addon_qf_layout

" order of formatters to be used when cycling
let s:c.quickfix_formatters = get(s:c, 'quickfix_formatters', ['NOP', 'vim_addon_qf_layout#DefaultFormatter', 'vim_addon_qf_layout#FormatterNoFilename', 'vim_addon_qf_layout#Reset'])

let s:c.lhs_cycle = get(s:c, 'lhs_cycle', '<buffer> \v')

" don't add more than 60 spaces to filenames when aligning
" If there are a couple of very long files only having too many spaces would
" be annoying
let s:c.file_name_align_max_width = 60

let s:c.hold_cursor = get(s:c, 'hold_cursor', 1)

" whenever the quickfix window gets opened, enhance it:
auto filetype qf call vim_addon_qf_layout#Quickfix()
