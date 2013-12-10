vim-addon-qf-layout
===================
A minimal quickfix layout cycler for VIM Marc Weber wants to maintain.
See credits below. Additional features might be merged or put into new
ropesitories later

How does it work?
=================
After :cope

* make modifiable
* %delete
* readding all quickfix item entries by call append(), this way you can change
  the formatting, eg choose to not show filenames or vertically align the texts

Usage:
=======

    :grep -ri 'something' .

Then put cursor in quickfix window, type \v to cycle layouts


Customization:
==============

    " This declares the defaults, so just add the keys to .vimrc you want to change
    let g:vim_addon_qf_layout = {}
    let g:vim_addon_qf_layout.quickfix_formatters = [ 'NOP', 'vim_addon_qf_layout#DefaultFormatter', 'vim_addon_qf_layout#FormatterNoFilename', 'vim_addon_qf_layout#Reset' ]
    let g:vim_addon_qf_layout.lhs_cycle = '<buffer> \v'
    let g:vim_addon_qf_layout.file_name_align_max_width = 60

    " Optionally you can define your own mappings like this:
    noremap \no_filenames call vim_addon_qf_layout#ReformatWith('vim_addon_qf_layout#FormatterNoFilename')<cr>


CREDITS TO Alex Leferry & Info about his original version
=========================================================

Credits to Alex Leferry 2 (alexherbo2 TA gmail.com) who showed me the initial
implementation and the idea.

His updated version might appear here:
https://github.com/alexherbo2/vim_addon_qf_layout.vim

His original version:
https://bitbucket.org/alexherbo2/dotfiles/src/09080c78ca0c15aeda428cffb98c18c24ed081c0/dead_scripts/quickfix.vim?at=master

Features his original version provides:
  1) set col of cursor
  2) on :cope jump to nearest line
  3) drop columns automatically if lines get too long, eg start by hiding the
     filename (do this by providing a new formatter function)
  4) provide a sample how to use ruby/python or such?
  5) set quickfix size to number of lines?
      maybe some more
  6) limit cols cursor can use
