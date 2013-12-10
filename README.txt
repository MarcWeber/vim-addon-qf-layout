			              _
			     __ _ ___| |_ ___  ___
			    / _` |_  / __/ _ \/ __|
			   | (_| |/ /| ||  __/ (__
			    \__,_/___|\__\___|\___|

                      The quickfix layout cycler for VIM


How does it work? After opening quickfix window
  1) make modifiable
  2) %delete
  3) readding all quickfix item entries by call append()

Step 3 can be customized by you.
Some sample implementations are used by default.,
see quickfix_formatters below.

Customization: Put in your ~/.vimrc:

" declare dictionary
let g:aztec = {}
" declare order of formatters
let g:aztec.quickfix_formatters = ['formatter-1', 'formatter-2', ..]
" which key to use for cycling (cursor must be in quickfix window, is this a nice choice?)
let g:aztec.lhs_cycle = '\your-left-hand-side-mapping'
" how many spaces to use for aligning file names.
" Using too much will require you to break lines, thus use a sane
" limit
let g:aztec.file_name_align_max_width = 60

defaults:

	quickfix_formatters:
	['NOP', 'aztec#DefaultFormatter', 'aztec#FormatterNoFilename', 'quickfix_enhancer#Reset']

	lhs_cycle:
	<buffer> \v

Optionally you can define your own mappings like this:
noremap \no_filenames call aztec#ReformatWith('aztec#FormatterNoFilename')<cr>

NOP means: :cope will not change default layout
DefaultFormatter: align line numbers and text
FormatterNoFilename: only show line numbers and text
Reset: switch back to default

All credits to alexherbo2 who provided both the initial implementation
and the idea.

maintainers:
- Alex Leferry 2 (alexherbo2 TA gmail.com)
- Marc Weber (marco-oweber TA gmx.de)

new repository (to be created)
https://github.com/alexherbo2/aztec.vim (TODO, create, add MarcWeber as collaborator)
 
TODO:
port missing features from his initial version, make some of the optional

Original version:
https://bitbucket.org/alexherbo2/dotfiles/src/09080c78ca0c15aeda428cffb98c18c24ed081c0/dead_scripts/quickfix.vim?at=master
1) set col of cursor
2) on :cope jump to nearest line
3) drop columns automatically if lines get too long, eg start by hiding the
   filename (do this by providing a new formatter function)
4) provide a sample how to use ruby/python or such?
5) set quickfix size to number of lines?

Think about loclist (show me anybody using it before making me work on anysuch .. )
