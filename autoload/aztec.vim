if !exists('g:aztec') | let g:aztec = {} | endif | let s:c = g:aztec

fun! aztec#Quickfix()
  " this is called on setfiletype auto command

  let is_quickfix = empty(getloclist(0))

  if is_quickfix

    setlocal colorcolumn=
    setlocal nowrap
    setlocal nolist
    setlocal modifiable

    let list = getqflist()

    if empty(list) | return
    end

    " Goto the last used window---
    wincmd W                      |
    "                             |
    let pos     =  getpos('.')    |
    let pos[0]  =   bufnr('%')    |
    "                             |
    " Goto Quickfix window--------
    wincmd w

    exec 'noremap '. s:c.lhs_cycle .' :call aztec#Cycle()<cr>'

    let b:aztec_cycle_id = 0
    call aztec#ReformatWith(s:c.quickfix_formatters[0])

    let nearest_entry = list[0]

    " TODO
    " exec 'cc' nearest_entry.number

    call setpos('.', [0] + pos[1:-1])

    wincmd w
  end

endf

fun! aztec#Cycle()
  if (!exists('b:aztec_cycle_id'))
    let b:aztec_cycle_id = 0
  endif
  let b:aztec_cycle_id += 1
  call aztec#ReformatWith(s:c.quickfix_formatters[b:aztec_cycle_id % len(s:c.quickfix_formatters)])
endf

fun! aztec#ReformatWith(f)
  " TODO: switch to quickfix window and switch back if this gets called
  " from somewhere else ..
  if &filetype != 'qf' | echoe "not in quickfix window, not formatting anything (TODO)" | return
  endif

  if a:f == 'NOP' | return | endif
  let F = a:f

  " delete old contents (luckily Vim will keep knowing which line belongs to
  " what entry ..
  %delete

  call call(F, [])

  " allow :q without vim yelling
  set nomodified
endf

" ===================== SAMPLE FORMATTERS

" Default sample implementation how you can reformat list items
" Its very important that for each item of list you append one line to the
" buffer only, otherwise Vim will be confused
" 
" This function is also responsible to add lines to buffer.
" If you want to call a python/ruby implementation it might be most efficient
" to do the appending in that if_* language
fun! aztec#DefaultFormatter()
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


fun! aztec#FormatterNoFilename()
  " same as above, but don't add filename
  let list = copy(getqflist())
  let max_lnum_len     = max(map(copy(list), 'len(v:val.lnum)'))
  " now reformat and append to buffer
  call append('0', map(list, 'printf("%'.max_lnum_len.'S| %s", v:val.lnum, v:val.text)'))
endf

fun! aztec#Reset()
  " default view
  call setqflist(getqflist())
endf

" Hold on ──────────────────────────────────────────────────────────────────────

" Hold the cursor between match(expr) and matchend(expr).
fun! aztec#Interface_hold_on(expr)

  let col  =     col('.')
  let line = getline('.')

  let [colstart,colend] = [match(line,a:expr),matchend(line,a:expr)]

  if (colstart<0) || (colend<0) | return
  end

  if (col<colstart)
    exec 'normal!' colstart . '|'
  end

  if (col>colend)
    exec 'normal!' colend . '|'
  end

endf
