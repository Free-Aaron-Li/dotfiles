#set page(
  paper: "a4",
  margin: (x: 1.8cm, y: 1.5cm),
)
#set text(
  size: 16pt,
  font: ("Noto Sans CJK SC","STIX Two Text","Source Han Serif SC")
)

#set heading(numbering: "1.")

= 数学公式

== 基本概念

- 在双 \$\$ 之间定义公式，\$空格 公式 空格\$的格式，公式会居中显示
- 公式中的单个字母被视为变量，可以用 \# 访问，多个字母要加引号
- 提供多种符号、变体以及类似 => 这样的速记序列,shezhghghahi
- 支持函数，接受命名和位置参数，在\$\$之外调用要加上 math. 前缀
- 可以给公式编号，也可用 <name> 标识公式，在文本用\@name 引用公式
- 常见公式形式,关于设置的：
- 关于设置

- this is something

#set math.equation(numbering: "(1)", supplement: [  公式:  ])

$ A = pi r^2 $
$ "area" = pi dot "radius"^2 $
$ cal(A) :=
{ x in RR | x "is natural" } $
#let x = 5
$ #x < 17 $

$ x < y => x gt.eq.not y $

$ frac(a^2, 2) $
$ vec(1, 2, delim: "[") $
$ mat(1, 2;3, 4) $
$ lim_x =
op("lim", limits: #true)_x $

#show math.sum: set text(size: 20pt)
$ sum_(i in NN) 1 + i $

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用公式的例子，根据 @ratio 可得：
$ F_n = floor(1 / sqrt(5) phi.alt^n) $

== 公式对齐
- 多步推导的公式还可以用&在等号处对齐
$ sum_(k=0)^n k
&= 1 + 2 + 3 + ... + n \
&= (n(n+1)) / 2 " (这里可添加说明)" \
&= 1/2(n(n+1)) \
&= 1/2(n^2+n) \
&= 1/2n^2+1/2n $

== 公式中的字体

#align(
  center)[
    #table(
      columns: (auto, auto),
      inset: 20pt,
      align: horizon,
      [  *Variants*  ],
      [  *Example*  ],
      "普通文本",
      "N B R",
      "serif",
      $serif(N B R)$,
      "sans",
      $sans(N B R)$,
      "frak",
      $frak(N B R)$,
      "mono",
      $mono(N B R)$,
      "bb",
      $bb(N B R)$,
      "cal",
      $cal(N B R)$,
    )
  ]

== accent 上标

#align(
  center)[
    #table(
      columns: (auto, auto),
      inset: 15pt,
      align: horizon,
      [  *accent*  ],
      [  *Example*  ],
      "grave",
      $grave(a)=accent(a, grave)$,
      "acute",
      $acute(a)=accent(a, acute)$,
      "acute.double",
      $acute.double(a)=acute.double(a)$,
      "hat",
      $accent(a, hat)=accent(a, hat)$,
      "tilde",
      //也可以直接指定unicode码
      $tilde(a) = accent(a, \u{0303})$,
      "macron",
      $macron(a)=accent(a, macron)$,
      "breve",
      $breve(a)=accent(a, breve)$,
      "diaer",
      $diaer(a)=diaer(a)$,
      "circle",
      $circle(a)=accent(a, circle)$,
      "caron",
      $caron(a)=accent(a, caron)$,
      "dot",
      $dot(a)=accent(a, dot)$,
      "dot.double",
      $dot.double(a)=dot.double(a)$,
      "dot.triple",
      $dot.triple(a)= dot.triple(a)$,
      "dot.quad",
      $dot.quad(a)= dot.quad(a)$,
      "arrow",
      $arrow("AB") = accent("AB", arrow)$,
      "arrow.l",
      $arrow.l("AB") = arrow.l("AB")$,
    )
  ]

== 方程的上下标和注释
#align(
  center)[
    #table(
      columns: (auto, auto),
      inset: 15pt,
      align: horizon,
      [  *Under/Over*  ],
      [  *Example*  ],
      "underline",
      $underline(1 + 2 + ... + 5)$,
      "overline",
      $overline(1 + 2 + ... + 5)$,
      "underbrace",
      $underbrace(1 + 2 + ... + 5, "numbers")$,
      "overbrace",
      $overbrace(1 + 2 + ... + 5, "numbers")$,
      "underbracket",
      $underbracket(1 + 2 + ... + 5, "numbers")$,
      "overbracket",
      $overbracket(1 + 2 + ... + 5, "numbers")$,
    )
  ]

== 在公式的其他位置附加符号
- 不用函数实现上下标
// With syntax.
$ sum_(i=0)^n a_i = 2^(1+i) $
- attach 函数
// With function call.
$ attach(
  Pi,
  t: alpha,
  b: beta,
  tl: 1,
  tr: 2+3,
  bl: 4+5,
  br: 6,
) $
- scripts 函数
$ scripts(sum)_1^2 != sum_1^2 $
- limits 函数
$ limits(A)_1^2 != A_1^2 $

== binom 组合数
- 从 n 个元素中取 k 个的组合数，例子：

$ binom(n, k) $

== cancel 删除、约分、化简
- 约分
$ (a dot b dot cancel(x)) /
cancel(x) $
- 约分多项并反转斜线
$ (a cancel((b + c), inverted: #true)) /
cancel(b + c, inverted: #true) $
- 删除
$ cancel(Pi, cross: #true) $

== cases 条件分支
- parentheses 小括号
$ f(x, y) := cases(
  delim: "(",
  1 "if" (x dot y)/2 <= 0,
  2 "if" x "is even",
  3 "if" x in NN,
  4 "else",
) $

- brackets 中括号
$ f(x, y) := cases(
  delim: "[",
  1 "if" (x dot y)/2 <= 0,
  2 "if" x "is even",
  3 "if" x in NN,
  4 "else",
) $
- 默认符号，curly braces 大括号
$ f(x, y) := cases(
  1 "if" (x dot y)/2 <= 0,
  2 "if" x "is even",
  3 "if" x in NN,
  4 "else",
) $
- vertical bars 竖线
$ f(x, y) := cases(
  delim: "|",
  1 "if" (x dot y)/2 <= 0,
  2 "if" x "is even",
  3 "if" x in NN,
  4 "else",
) $
- double vertical bars 双竖线
$ f(x, y) := cases(
  delim: "||",
  1 "if" (x dot y)/2 <= 0,
  2 "if" x "is even",
  3 "if" x in NN,
  4 "else",
) $

== 分数和除法
$ 1/2 < (x+1)/2 $
$ ((x+1)) / 2 = frac(a, b) $

== 常见函数和括号的缩放
- abs 函数
$ abs(x/2) $
- norm 函数
$ norm(x/2) $
- floor 函数
$ floor(x/2) $

- ceil 函数
$ ceil(x/2) $
- round 函数
$ round(x/2) $
- 缩放括号
$ lr((a, (b-1/2), c), size: #50%) $
$ lr((a, (b/2),c), size: #150%) $

== vector 向量
- 默认符号，parentheses 小括号
$ vec(, a, b, c) dot vec(1, 2, 3) = a + 2b + 3c $
- brackets 中括号
$ vec(delim: "[", a, b, c) dot vec(delim: "[", 1, 2, 3) = a + 2b + 3c $
- curly braces 大括号
$ vec(delim: "{", a, b, c) dot vec(delim: "{", 1, 2, 3) = a + 2b + 3c $
- vertical bars 竖线
$ vec(delim: "|", a, b, c) dot vec(delim: "|", 1, 2, 3) = a + 2b + 3c $
- double vertical bars 双竖线
#set math.vec(delim: "||")
$ vec(, a, b, c) dot vec(1, 2, 3) = a + 2b + 3c $

== matrix 矩阵
- 默认符号，parentheses 小括号
$ mat(1, 2;3, 4) $

- brackets 中括号
$ mat(
  delim: "[",
  1, 2, ..., 10;2, 2, ..., 10;dots.v, dots.v, dots.down, dots.v;10, 10, ..., 10;, , , , , ,,
) $
- curly braces 大括号 
$ mat(
  delim: "{",
  1, 2, ..., 10;2, 2, ..., 10;dots.v, dots.v, dots.down, dots.v;10, 10, ..., 10;, , , , , ,,
) $
- vertical bars 竖线
$ mat(
  delim: "|",
  1, 2, ..., 10;2, 2, ..., 10;dots.v, dots.v, dots.down, dots.v;10, 10, ..., 10;, , , , , ,,
) $
- double vertical bars 双竖线
$ mat(
  delim: "||",
  1, 2, ..., 10;2, 2, ..., 10;dots.v, dots.v, dots.down, dots.v;10, 10, ..., 10;, , , , , ,,
) $

== root function 开方与根号
$ sqrt(x^2) = x = sqrt(x)^2 $

$ root(3, x^3) = x = root(3, x)^3 $ 

- 加个括号：

$ root(n, x^n) = x = （root(n, x)）^ n $

== 预定义的函数和自定义函数
- 正余弦和正余切
$ tan x = (sin x)/(cos x) $
$ cot x = (cos x)/(sin x) $

- 自定义函数
$ op(
  "myop",
  limits: #true,
)_(n->oo) n $

- 其他预定义函数

#align(
  center)[
    #table(
      columns: (auto, auto),
      inset: 10pt,
      align: horizon,
      [  *函数*  ],
      [  *说明*  ],
      "arccos",
      "反余弦函数",
      "arcsin",
      "反正弦函数",
      "arctan",
      "反正切函数",
      "arg",
      "辐角函数",
      "cos",
      "余弦函数",
      "cosh",
      "双曲余弦函数",
      "cot",
      "余切函数",
      "ctg",
      "余切函数",
      "coth",
      "双曲余切函数",
      "csc",
      "余割函数",
      "deg",
      "角度制转换函数",
      "det",
      "矩阵行列式",
      "dim",
      "向量空间维数",
      "exp",
      "指数函数",
      "gcd",
      "最大公约数",
      "hom",
      "同态函数",
      "inf",
      "下确界",
      "ker",
      "核函数",
      "lg",
      "以 10 为底的对数函数",
      "lim",
      "极限函数",
      "ln",
      "自然对数函数",
      "log",
      "对数函数",
      "max",
      "最大值函数",
      "min",
      "最小值函数",
      "Pr",
      "概率函数",
      "sec",
      "正割函数",
      "sin",
      "正弦函数",
      "sinc",
      "sinc 函数",
      "sinh",
      "双曲正弦函数",
      "sup",
      "上确界",
      "tan",
      "正切函数",
      "tg",
      "正切函数",
      "tanh",
      "双曲正切函数",
      "liminf",
      "下极限函数",
      "limsup",
      "上极限函数",
    )
  ]
