" commit-mates.vim - Add co-authors to git commits
" Maintainer: Your Name
" License: MIT

if exists('g:loaded_commit_mates')
  finish
endif
let g:loaded_commit_mates = 1

command! CommitMates lua require('commit-mates').open_window()
