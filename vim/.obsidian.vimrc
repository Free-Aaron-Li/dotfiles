" 退出方式
imap <A-Space> <Esc>
vmap <A-Space> <Esc>

" 光标移动
imap <A-h> <Left>
imap <A-l> <Right>
imap <A-j> <Down>
imap <A-k> <Up>

" 行首行尾移动
nmap <A-;> 0
nmap <A-'> $
imap <A-;> <Esc>0i
imap <A-'> <Esc>$a

" 换行
imap <S-CR> <Esc>o

" 连接系统剪贴板
set clipboard=unnamed

" 命令模式输入法切换
