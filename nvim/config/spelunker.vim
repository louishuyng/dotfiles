let g:enable_spelunker_vim = 1
let g:enable_spelunker_vim_on_readonly = 0
let g:spelunker_target_min_char_len = 4
let g:spelunker_max_suggest_words = 15
let g:spelunker_max_hi_words_each_buf = 100
let g:spelunker_check_type = 1
let g:spelunker_highlight_type = 1
let g:spelunker_disable_auto_group = 1
augroup spelunker
	autocmd!
	autocmd BufWinEnter,BufWritePost *.vim,*.js,*.jsx,*.json,*.md call spelunker#check()
	autocmd CursorHold *.vim,*.js,*.jsx,*.json,*.md call spelunker#check_displayed_words()
augroup END
let g:spelunker_spell_bad_group = 'SpelunkerSpellBad'
let g:spelunker_complex_or_compound_word_group = 'SpelunkerComplexOrCompoundWord'
highlight SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=#e84118
highlight SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE
