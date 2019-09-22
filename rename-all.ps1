# 比较简陋 但方便的 批量替换文件名

# 旧名称中的匹配字符串 用于替换该字符串的新名称 文件类型筛选
param($oldtext, $newtext, $filter)

# PowerShell3.0之前 $CurrentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
# 脚本文件路径
#$RenameWorkPath = $PSScriptRoot

# PowerShell进程当前所处路径
$RenameWorkPath = (gi .).FullName.ToString()

# 定义过滤条件
#$Filter = '*.png'
$Filter = $filter
#$newtext = 'newName'
# 如果名称过于简单比如en可能会: 无法重命名指定的目标，因为该目标表示路径或设备名称。
#$oldtext = 'oldname'

# $host.UI.WriteErrorLine
Write-Host("将[" + $RenameWorkPath + "]路径下名称带有[" + $oldtext + "]且包含[" + $filter + "]的所有项目的名称 替换为[" + $newtext + "]") -ForegroundColor Red -BackgroundColor Gray
$oP = ($RenameWorkPath + "/*" + $oldtext + "*");
$oP
# Rename-Item 可以作用于文件夹 但是这里筛选貌似不大方便
$includeItem = ls $oP -Include $Filter -Recurse -File;
pause
$includeItem | out-host -paging
$sure = Read-Host '请确认执行上述替换 若替换了错误的项目 无法撤销! y/n 除了y都表示取消'

if($sure-eq'y'){
    $count = 0;
    $includeItem  | ForEach-Object{
        # 默认情况下 catch 语句无法捕获 Non-Terminating Errors
        # [PowerShell 异常处理 - sparkdev - 博客园](https://www.cnblogs.com/sparkdev/p/8376747.html)
        # [Rename-Item](https://docs.microsoft.com/zh-CN/powershell/module/microsoft.powershell.management/rename-item?view=powershell-6)
        try{
            Rename-Item -Path $_.FullName -NewName $_.Name.Replace($oldtext, $newtext) -ErrorAction Stop;
            $_.FullName
            ++$count;
        }catch{
            Write-Error($PSItem.ToString());
        }
    }
    Write-Output($Path+'中所有匹配的文件' + $count + '个重命名成功');
}else{
    "重命名操作已取消"
}
