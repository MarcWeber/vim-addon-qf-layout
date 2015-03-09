if !exists('g:vim_addon_qf_layout') | let g:vim_addon_qf_layout = {} | endif | let s:c = g:vim_addon_qf_layout

fun! vim_addon_qf_layout#Quickfix()
  " this is called on setfiletype auto command

  let is_quickfix = empty(getloclist(0))

  if is_quickfix

    setlocal colorcolumn=
    setlocal nowrap
    setlocal nolist


    if empty(getqflist()) | return | endif

    exec 'noremap <buffer> '. s:c.lhs_cycle .' :call vim_addon_qf_layout#Cycle()<cr>'

    let b:vim_addon_qf_layout_cycle_id = 0
    call vim_addon_qf_layout#ReformatWith(s:c.quickfix_formatters[0])

  end

endf

fun! vim_addon_qf_layout#Cycle()
  if (!exists('b:vim_addon_qf_layout_cycle_id'))
    let b:vim_addon_qf_layout_cycle_id = 0
  endif
  let b:vim_addon_qf_layout_cycle_id += 1
  call vim_addon_qf_layout#ReformatWith(s:c.quickfix_formatters[b:vim_addon_qf_layout_cycle_id % len(s:c.quickfix_formatters)])
endf

fun! vim_addon_qf_layout#ReformatWith(f)
  " TODO: switch to quickfix window and switch back if this gets called
  " from somewhere else ..
  if &filetype != 'qf' | echoe "not in quickfix window, not formatting anything (TODO)" | return
  endif

  let pos =  getpos('.')
  if a:f == 'NOP' | return | endif
  let F = a:f

  setlocal modifiable

  " delete old contents (luckily Vim will keep knowing which line belongs to
  " what entry ..
  %delete

  call call(F, [])

  call setpos('.', [0] + pos[1:-1])

  setlocal nomodifiable

  " allow :q without vim yelling
  setlocal nomodified
endf

" ===================== SAMPLE FORMATTERS

" Default sample implementation how you can reformat list items
" Its very important that for each item of list you append one line to the
" buffer only, otherwise Vim will be confused
" 
" This function is also responsible to add lines to buffer.
" If you want to call a python/ruby implementation it might be most efficient
" to do the appending in that if_* language
fun! vim_addon_qf_layout#DefaultFormatter()
  let list = copy(getqflist())
  " not sure whether copy is needed. I once had a segfault.. maybe its
  " obsolete nowadays.

  for l in list
    let l.filename = bufname(l.bufnr)
  endfor

  let max_filename_len = max(map(copy(list), 'len(v:val.filename)' ))
  let max_lnum_len     = max(map(copy(list), 'len(v:val.lnum)'))

  let max_filename_len = min([s:c.file_name_align_max_width, max_filename_len])

  " now reformat and append to buffer
  call append('0', map(list, 'printf("%-'.max_filename_len.'S|%'.max_lnum_len.'S| %s", v:val.filename, v:val.lnum, v:val.text)'))
endf


fun! vim_addon_qf_layout#FormatterNoFilename()
  " same as above, but don't add filename
  let list = copy(getqflist())
  let max_lnum_len     = max(map(copy(list), 'len(v:val.lnum)'))
  " now reformat and append to buffer
  call append('0', map(list, 'printf("%'.max_lnum_len.'S| %s", v:val.lnum, v:val.text)'))
endf

fun! vim_addon_qf_layout#Reset()
  " default view
  call setqflist(getqflist())
endf

