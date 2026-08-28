" 退出方式
imap <M-Space> <Esc>
vmap <M-Space> <Esc>

" 光标移动（插入模式下使用 Option+hjkl 移动）
imap <M-h> <Left>      " 向左移动一个字符
imap <M-l> <Right>     " 向右移动一个字符
imap <M-j> <Down>      " 向下移动一行
imap <M-k> <Up>        " 向上移动一行

" 行首行尾移动
nmap <A-;> 0
nmap <A-'> $
imap <A-;> <Esc>0i
imap <A-'> <Esc>$a

" 换行
imap <S-CR> <Esc>o

" 连接系统剪贴板
set clipboard=unnamed
