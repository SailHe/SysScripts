# SysScripts
PowerShell, Python, Javascript, Bash 等各种系统层面的脚本

## PowerSehll
- renameAll.ps1 (批量替换文件名)   
   - 为防止误操作工作目录已写死, 请自行替换或是更改行为
   - 可筛选
   - 支持匹配文件名
- netLink.ps1(以目录为单位的程序的网络连接行为监听)   
   - 查看指定条件下(路径)程序的tcp网络连接情况 实时(间隔1s)刷新;
   - 如果没有更新则不输出(增加时会检测出来增量, 减少时不作变动)
- searchContext.ps1(递归目录上下文搜索)
   - 支持中文IO
   - 支持匹配 文件名, 文件内容, 目录名(根目录是进程执行时的环境所处的目录)
