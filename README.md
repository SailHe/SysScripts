# SysScripts
PowerShell, Python, Javascript, Bash 等各种系统层面的脚本

## PowerSehll
- renameAll.ps1
批量替换文件名(为了防止误操作替换时的工作目录已写死请自行替换或是更改行为)
- netLink.ps1
查看指定条件下(路径)程序的tcp网络连接情况 实时(间隔1s)刷新; 如果没有更新则不输出(增加时会检测出来增量, 减少时不作变动)
- searchContext.ps1
递归目录上下文搜索: 支持中文IO 支持匹配 文件名, 文件内容, 目录名(搜索的根目录是进程执行时的环境所处的目录)
