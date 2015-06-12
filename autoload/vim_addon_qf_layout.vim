if !exists('g:vim_addon_qf_layout') | let g:vim_addon_qf_layout = {} | endif | let s:c = g:vim_addon_qf_layout

fun! vim_addon_qf_layout#Quickfix()
  " this is called on setfiletype auto command

  if empty(vim_addon_qf_layout#GetList()) | return | endif

  setlocal colorcolumn=
  setlocal nowrap
  setlocal nolist

  redraw!

  exec 'noremap <silent> <buffer> '. s:c.lhs_cycle .' :call vim_addon_qf_layout#Cycle()<cr>'

  let spec_formatter = vim_addon_qf_layout#GetSpecFormatter()
  if !empty(spec_formatter)
    call vim_addon_qf_layout#ReformatWith(spec_formatter)
    let b:vim_addon_qf_layout_cycle_id = -1
  else
    " vim_addon_qf_layout#Reset() triggers autocmd filetype; thus the
    " existence of the variable is used to determine if it is the first one.
    if (!exists('b:vim_addon_qf_layout_cycle_id'))
      let b:vim_addon_qf_layout_cycle_id = 0
      call vim_addon_qf_layout#ReformatWith(s:c.quickfix_formatters[0])
    endif
  endif
endf

fun! vim_addon_qf_layout#Cycle()
  if (!exists('b:vim_addon_qf_layout_cycle_id'))
    let b:vim_addon_qf_layout_cycle_id = 0
  endif
  let b:vim_addon_qf_layout_cycle_id += 1
  let formatter = s:c.quickfix_formatters[b:vim_addon_qf_layout_cycle_id % len(s:c.quickfix_formatters)]
  call vim_addon_qf_layout#ReformatWith(formatter)
  echom '[addon-qf-layout] cycle: ' . formatter
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
  let last_line = line('$')
  silent %delete
  call call(F, [])
  if line('$') > last_line 
    silent $delete " remove the extra line after the appended text
  endif

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
  let list = copy(vim_addon_qf_layout#GetList())
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
  let list = copy(vim_addon_qf_layout#GetList())
  let max_lnum_len     = max(map(copy(list), 'len(v:val.lnum)'))
  " now reformat and append to buffer
  call append('0', map(list, 'printf("%'.max_lnum_len.'S| %s", v:val.lnum, v:val.text)'))
endf

fun! vim_addon_qf_layout#Reset()
  " default view
  call vim_addon_qf_layout#SetList(vim_addon_qf_layout#GetList())
endf

"return the result from either getqflist() or getloclist()
fun! vim_addon_qf_layout#GetList()
  if vim_addon_qf_layout#isLocList()
    return getloclist(0)
  else
    return getqflist()
  endif
endf


"apply the right choice from either setqflist() or setloclist()
fun! vim_addon_qf_layout#SetList(list)
  if vim_addon_qf_layout#isLocList()
    call setloclist(0, a:list)
  else
    call setqflist(a:list)
  endif
endf

"return true if the current window is a location list
fun! vim_addon_qf_layout#isLocList()
  " it is necessary to check the current filename a location list may have no
  " elements (e.g.: lgrep return no matches)
  redir => l:ctrl_g
  silent file
  redir END

  if !empty(getloclist(0)) || l:ctrl_g =~ 'Location List'
    return 1
  endif
  return 0
endf

"return specific formatter for location list or quickfix when available
fun! vim_addon_qf_layout#GetSpecFormatter()
  " clear the filter after used to avoid issues with cnext/cold
  " w:vim_addon_qf_layout_temp_formatter can be used to set specific formats
  " depending on the quickfix command used through QuickFixCmdPost. It is
  " not possible to use a dict with custom formatters for each command
  " because 1) the w:quickfix_title is set only after the relevant autocmds
  " are executed and 2) w:quickfix_title isn't updated with cnext and cold.
  " Maybe this can be improved after this patch is completed/accepted:
  " https://groups.google.com/forum/#!topic/vim_dev/X7VVPd4Do5s

  if exists('w:vim_addon_qf_layout_temp_formatter')
    let formatter = w:vim_addon_qf_layout_temp_formatter
    unlet w:vim_addon_qf_layout_temp_formatter
    return formatter
  else
    " if the quickfix/location list was closed then the specific formatter may
    " be present on the previous window
    let formatter = getwinvar(winnr('#'),'vim_addon_qf_layout_temp_formatter')
    call setwinvar(winnr('#'),'vim_addon_qf_layout_temp_formatter', '')
    return formatter
  endif
endf
