# 批量替换文件名

# 旧名称中的匹配字符串 用于替换该字符串的新名称 文件类型筛选
param($oldtext, $newtext, $filter)

# 定义保存了文件的目录 为了防止误操作 将此参数写死
$Path = 'F:\Temper\RenameWorkSpace'

# PowerShell3.0之前 $CurrentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
# 脚本文件路径
#$Path = $PSScriptRoot

# PowerShell进程当前所处路径
#$Path = "'" + (gi .).FullName.ToString() + "'"

# 定义过滤条件
#$Filter = '*.png'
$Filter = $filter
#$newtext = 'newName'
# 如果名称过于简单比如en可能会: 无法重命名指定的目标，因为该目标表示路径或设备名称。
#$oldtext = 'oldname'
Write-Output('旧字符串' + $oldtext);
Write-Output('新字符串' + $newtext);
Write-Output('筛选器' + $filter);

$count = 0;
ls $Path -Include $Filter -Recurse | ForEach-Object{
    if($_.FullName.Contains($oldtext)){
        ++$count;
        Rename-Item $_.FullName $_.FullName.Replace($oldtext, $newtext);
    }
}
Write-Output($Path+'中所有匹配的文件' + $count + '个重命名成功');
