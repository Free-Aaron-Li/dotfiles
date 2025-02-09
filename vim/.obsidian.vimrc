" 退出方式
imap <A-Space> <Esc>
vmap <A-Space> <Esc>

" 光标移动
imap <A-h> <Left>
imap <A-l> <Right>
imap <A-j> <Down>
imap <A-k> <Up>
nmap <A-h> 5h
nmap <A-l> 5l

" 行首行尾移动
nmap <A-;> 0
nmap <A-'> $
imap <A-;> <Esc>0i
imap <A-'> <Esc>$a

" I like using H and L for beginning/end of line
nmap H ^
nmap L $

" 连接系统剪贴板
set clipboard=unnamed
