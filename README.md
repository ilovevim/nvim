### Neovim插件配置

Neovim版本很多，如果图省事，那么类似于LazyVim之类市场上有好多款可开箱就用。如果想从零开始自己折腾，最大化自由度，那么基于Kickstart模板配置是一个不错的选择。

关于如何搜索各种插件，github上的rockerBOO/awesome-neovim已经做了非常详细的梳理，强烈推荐！其分类详细几乎囊括了所有可能会用到的插件，但也正是因为其分类详细、数量庞杂，读者往往无所适从，不知该用那一款。针对这个问题，一种办法是看谁的star高，1k以上的通常都是质量不错的，但是1k以内的其实也不能完全看star高低来做比较。

下面，笔者梳理了一些插件的安装和使用心得，也尝试做了些横向比较供vim爱好者们参考。需要特别提醒的是，比较的维度可能是纯个人主观的想法，只有真正自己安装使用后才知道是不是符合自己的操作习惯，是不是“好用”。

由于mini系列插件功能强大，而且追求极致精简的理念深得我意，所以能用mini代替的尽可能都换了，目前用到了ai、surround、files、splitjoin、tabline、cursorword、trailspace、indentscope、operators等子插件。

1.  lazy.nvim插件管理

    大名鼎鼎的telescope、treesitter、nvim-web-devicons等不用犹豫太多，装上就是。

    | 插件功能     | 点评                                                                         |
    | ------------ | ---------------------------------------------------------------------------- |
    | surround     | nvim-surround很强大，用mini.surround平替                                     |
    | 光标移动     | flash.nvim，其他hop、leap用习惯了其实也可以                                  |
    | 词高亮       | vim-highlighter（f键方便），interestingwords不灵巧                           |
    | 折叠插件     | nvim-ufo、fold-preview等都弃用了                                             |
    | bufferline   | bufferline有点臃肿，且标签太宽放不了几个文件，mini.tabline平替，目前用barbar |
    | statusline   | lualine很强大，mini.statusline可平替，但为了集成navic面包屑，沿用lualine     |
    | winbar       | nvim-navic直接集成到lualine中，不再需要barbecue                              |
    | 文件树       | nvim-tree足够好，目前用neo-tree（伴随kickstart升级）                         |
    | LSP相关      | lspsaga、trouble花里胡哨用处不大，相关功能集成到telescope即可                |
    | LSP进度提示  | fidget                                                                       |
    | AICode       | avante太臃肿，目前用codecompanion，fittencode免费，codeium需要翻墙           |
    | 代码补全     | 老牌nvim-cmp，目前用blink.cmp（伴随kickstart升级），coq_nvim等没再去试       |
    | 代码调用树   | litee、litee-calltree太重，试用后已卸载                                      |
    | 代码大纲     | 建议轻量级aerial，vista.vim偏重                                              |
    | 函数签名浮窗 | blink.cmp原生支持，lsp_signature已弃用，cmp-nvim-lsp-signature-help有点问题  |
    | 函数参数高亮 | hlargs                                                                       |
    | 代码注释     | mini.comment，Comment.nvim额外支持行尾加注释                                 |
    | 代码调试     | nvim-dap，再搭配不同语言调试器，比如python的debugpy                          |
    | rest客户端   | kulala，rest.nvim要求装的luarocks会导致版本混乱不能用                        |
    | sql相关插件  | 考虑nvim-dbee，sqls.nvim仅支持mysql少数几种数据除                            |
    | latex相关    | vimtex                                                                       |
    | markdown相关 | markdown-preview                                                             |
    | 通知框       | noice.nvim+nvim-notify，其他fidget、mini.notify没多试                        |
    | 按键提示     | which-key                                                                    |
    | themes       | tokyonight、hybrid、kanagawa纯个人喜好                                       |
    | 版本管理     | gitsigns、neogit等                                                           |
    | 会话管理     | auto-session，neovim-session-manager易报错                                   |
    | 终端切换     | toggleterm，vim-floaterm评价也很高                                           |

1.  Mason插件管理（LSP、DAP、Linter、Formatter）
    | 插件功能 | 点评 |
    | ---------- | ---------------------------------------------------------------- |
    |python|pyright+ruff即可，pylyzer、jedi、basepyright等提示找不到stub文件，调试用debugpy|
    |java|jdtls，调试用java-debug-adapter|
    |latex|ltex-ls|
    |markdown|marksman|
    |lua|lua_ls、stylua|
    |c|clangd|
    |Formater|prettierd等|

### Neovim冷门命令

1. 搜索、替换
   | 命令:?,/,s | 功能 |
   | ------------------ | -------------------------------- |
   |/\v[\u4e00-\u9fff]+ | 查找中文 |
   |/foo\(bar\)\@= | "foo" in "foobar" |
   |/foo\(bar\)\@! | any "foo" not followed by "bar" |
   |/\(foo\)\@<!bar | any "bar" that's not in "foobar" |
   |/\(\/\/.\*\)\@<!in | "in" which is not after "//" |
   |:%s/\%u200b//gc |删除Unicode字符<200b>，代表零宽空格|
1. global
   | 命令:global | 功能 |
   | ------------------ | -------------------------- |
   |:g/foo/-1p|打印匹配所在行的前一行|
   |:g/foo/-1,.p|打印匹配所在行的前一及本行|
   |:g/foo/-1,+1p|打印匹配所在行的前后行|

1. 其他
   | 命令:其他 | 功能 |
   | ------------------ | -------------------------- |
   |:browse oldfiles!|打开oldfiles（所有打开过的terminal和buffer）|
   |:filter /^foo/ oldfiles|过滤oldfiles文件|
   |:lua vim.print()|传入table对象并打印，类似vim.inspect()函数|
   |:e ++enc=gbk|文件乱码时重新按指定字符集加载文件，GB18030是GBK的超集|
   |:redir @+ \| set rtp \| redir END|输出结果重定向至指定寄存器|

### 插件使用记录

| 日期     | 插件名称     | 点评                                               |
| -------- | ------------ | -------------------------------------------------- |
| 20250528 | pretty_hover | 额外增加转义符影响阅读，比如[...]会显示成\\[...\\] |
