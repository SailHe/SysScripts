# 递归目录上下文搜索(支持中文IO) 支持匹配 文件名, 文件内容, 目录名
# 搜索的根目录是进程执行时的环境所处的目录

param
(
# [string]$FileName=$(throw "Parameter missing: -FileName FileName"), # 强制要求参数
[string]$FileName,
[string]$DirName,
[string]$FileInfo
)

$parMap = @{}
$parMap.Add("FileName", $FileName)
$parMap.Add("FileInfo", $FileInfo)

$contextType = $null

if(!$FileName -and !$DirName){
     # 都没有输入表示默认搜索文件
    # 脚本默认参数 (还有'全局'默认参数)
    # 此处if里面的改动貌似被{}给限制了 只想到这个办法
    $parMap["FileName"] = "*.txt"
}

$FileName = $parMap["FileName"]
$FileInfo = $parMap["FileInfo"]

"子目录递归匹配 ->"
if($FileName){
    "文件名称: [" + $FileName + "]"
    $contextType = [IO.fileinfo]
    if($FileInfo){
        # $parMap["FileInfo"] = " " # 至少得是个空格
        "文本内容: [" + $FileInfo + "]"
        Get-ChildItem -s | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $FileName } | 
            ForEach-Object { Select-String -Path $_.PSPath -Pattern $FileInfo -Casesensitive -SimpleMatch }  | 
                group Path
    }else{
        Get-ChildItem -s | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $FileName } | 
                # % PSPath # 除非是输出单个属性(没有其余操作)才能不用花括号以及$_
                % {$_.PSPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "")}
    }
}
if($DirName){
    "目录名称: [" + $DirName + "]"
    $contextType = [IO.DirectoryInfo]
    Get-ChildItem -s | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $DirName } | 
                % {$_.PSPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "")}
}

