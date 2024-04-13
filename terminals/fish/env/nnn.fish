set -gx NNN_PLUG 'o:fzopen;j:autojump;p:preview-tui;i:imgview'
set -gx NNN_BMS 'p:~/Dev/Projects;b:~/Dev/Books;d:~/Downloads'

set -gx NNN_FCOLORS '000E63100000000000000000'

set -gx NNN_FIFO "/tmp/nnn.fifo"
set -gx NNN_OPENER open

set -l BLK "04"
set -l CHR "04"
set -l DIR "04"
set -l EXE "00"
set -l REG "00"
set -l HARDLINK "00"
set -l SYMLINK "06"
set -l MISSING "00"
set -l ORPHAN "01"
set -l FIFO "0F"
set -l SOCK "0F"
set -l OTHER "02"

set -gx NNN_FCOLORS "$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER"
