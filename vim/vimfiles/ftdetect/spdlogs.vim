" match BuildLog.txt files to the YAML language, which provides
" reasonable colorscheme for viewing build logs.  
" To install, copy this file to /cygdrive/C/Users/<username>/Vim/vimfiles/ftdetect/
au BufRead,BufNewFile BuildLog.txt set filetype=YAML
