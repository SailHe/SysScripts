# Tutorials

取之互联网 还之互联网, 所有内容以教学式方式列出(意指有实际的情景, 而不像API文档一样[字典式]地列出)

## PowerSehll
- searchContext.ps1
递归目录上下文搜索(支持中文IO) 支持匹配 文件名, 文件内容, 目录名(搜索的根目录是进程执行时的环境所处的目录)
### 简单语法
 - 行注释符'#'；块注释符'<#' 和 '#>'
 - 入门示例:   
 列举(ls)$Path变量的子目录中包含(Include)过滤变量($Filter)筛选后的元素, 然后将处理结果通过管道('|') 传给元素遍历器(ForEach-Object)中的代码进一步处理
``` PowerSehll
    ls $Path -Include $Filter -Recurse | ForEach-Object{Rename-Item $_.FullName $_.FullName.Replace($oldtext, $newtext);}
```
[白话翻译](http://www.aichunjing.com/xtjc/2017-03-09/2030.html)
> ls意思是获取目录，后面跟上$Path就是获取这个变量内的目录，参数-Include意思是包含，跟上$Filter这个变量用于过滤，之后通过管道处理“|”，ForEach-Object意思是个性化处理，花括号里的内容为： { 重命名 $_.全名 $_.全名.替换（‘$oldtext’,‘$newtext’）}（$_表示当前数据，即刚才获取的目录下的所有mkv文件）

# 常用cmdlet
```
Get-Process # 获取当前运行的所有进程
Get-Alias ps # 获取别名'ps'的完整名称
Get-Alias ?
#CommandType     Name                                               Version    Source                                                                          
#-----------     ----                                               -------    ------                                                                          
#Alias           % -> ForEach-Object                                                                                                                           
#Alias           ? -> Where-Object                                                                                                                             
#Alias           h -> Get-History                                                                                                                              
#Alias           r -> Invoke-History
```

### 常用网站
#### 历史

[注释](https://www.jb51.net/article/53281.htm)

[路径获取](http://www.bathome.net/thread-44889-1-1.html)


