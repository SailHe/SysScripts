# 递归目录上下文搜索(支持中文IO) 支持匹配 文件名, 文件内容, 目录名
# 搜索的根目录是进程执行时的环境所处的目录
# https://docs.microsoft.com/zh-cn/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-6
# https://www.pstips.net/accessing-files-and-directories.html

param
(
# [string]$FileName=$(throw "Parameter missing: -FileName FileName"), # 强制要求参数
[string]$FileName,
[string]$DirName,
[string]$FileInfo,
[int]$Depth,
[int]$DisCreateDay,
[switch]$isToday,
[switch]$isShowDirInfo,

#排除某些文件夹名称
[switch]$isTextFile,
[switch]$isHtmlFile,
[switch]$isMarkdownFile,
[switch]$isLogFile,
[switch]$isJsonFile,
[switch]$isAllFile,

[switch]$isNotNodePath,
[switch]$isNotCacheDir,
[switch]$isNotTempDir
)

#定义一个强类型变量 包含列表
# 文件包含
[string[]]$includeFileList = $null
# 排除目录名
[string[]]$excludeDirList = $null
# 排除路径名
[string[]]$excludePathList = $null

$parMap = @{}
$parMap.Add("FileName", $FileName)
$parMap.Add("FileInfo", $FileInfo)
$parMap.Add("Depth", $Depth)
#$parMap.Add("OrFile", "1")
$parMap.Add("DisCreateDay", $DisCreateDay)

$contextType = $null

if(!$FileName -and !$DirName){
     # 都没有输入表示默认搜索文件
    # 脚本默认参数 (还有'全局'默认参数)
    # 此处if里面的改动貌似被{}给限制了 只想到这个办法
    $parMap["FileName"] = "*"
}

if(!$Depth){
    $parMap["Depth"] = 1
}

if(!$DisCreateDay -and !$isToday){
    $parMap["DisCreateDay"] = -365
}

$FileName = $parMap["FileName"]
$FileInfo = $parMap["FileInfo"]
$Depth = $parMap["Depth"]
$DisCreateDay = $parMap["DisCreateDay"]

# $DisCreateDay > 0 表示将此变量内容输出到一个名为0的文件
if($DisCreateDay -gt 0){
 #Write-Error("创建时间只能选取之前的")
 "你选择了一个未来的时间点 请确认存在那样的项目"
}

# 2级递归 包含项目(文件夹 或 文件)名称为 "*.json" 和 *.log(可不加双引号) 排除项目"nodemon*" 和 "*toolkit*"
#  Get-ChildItem -s -Depth 2 -Include "*.json" , *.log  -Exclude "nodemon*", "*toolkit*"
if($isTextFile){
 $includeFileList += "*.txt"
}
if($isHtmlFile){
 $includeFileList += "*.html"
}
if($isMarkdownFile){
 $includeFileList += "*.md"
}
if($isLogFile){
 $includeFileList += "*.log"
}
if($isJsonFile){
 $includeFileList += "*.json"
}
if($isAllFile){
 $includeFileList = "*"
}

if($isNotNodePath){
 $excludePathList += "*node_modules*"
}
if($isNotCacheDir){
 $excludeDirList += "*cache*"
}
if($isNotTempDir){
 $excludeDirList += "*temp*"
 $excludeDirList += "*tmp*"
}

"子目录递归匹配"
"递归深度" + $Depth
"包含文件列表" + $includeFileList
"时间距离" + $DisCreateDay
" ->"

function trimPsPath([string]$psPath){
 return $psPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "");
}

$reaultCount = 0;
$fullPath = (gi .).FullName.ToString()

# Get-ChildItem别名: Dir; ls(来自UNIX家族)
if($FileName){
    "正则文件名称: [" + $FileName + "]"
    $contextType = [IO.fileinfo]
    if($FileInfo){
        # $parMap["FileInfo"] = " " # 至少得是个空格
        "文本内容: [" + $FileInfo + "]"
        ""
        # -File 可以筛选文件
        Get-ChildItem -s -Depth $Depth -File -Include $includeFileList | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $FileName -and $_.CreationTime -gt (Get-Date).AddDays($DisCreateDay) } | 
            ForEach-Object { Select-String -Path $_.PSPath -Pattern $FileInfo -Casesensitive -SimpleMatch }  | 
                group Path | % {
                    "";
                    # 减掉首部的'\'以及尾部的文件名
                    "目录深度: " + ($_.Values.Replace($fullPath, "").Split('\').Length - 2)
                    #$_.Name;
                    $_.Count.ToString() + "处 路径位于 -> " + $_.Values;
                    if($isShowDirInfo){
                        "____________________________=子路径|匹配行数|匹配内容=____________________________";
                        $_.Group;
                    }
                    "";
                    $reaultCount = $reaultCount + 1;
                }
    }else{
        Get-ChildItem -s -Depth $Depth -Include $includeFileList | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $FileName } | 
                # % PSPath # 除非是输出单个属性(没有其余操作)才能不用花括号以及$_
                % {
                    trimPsPath($_.PSPath.ToString());
                    $reaultCount = $reaultCount + 1;
                }
    }
    "搜索文件数:" + $reaultCount;
}
if($DirName){
    "排除目录列表" + $excludeDirList
    "排除路径列表" + $excludePathList
    "模糊目录名称: [" + $DirName + "]"
    ""
    $contextType = [IO.DirectoryInfo]
    # -Exclude 仅排除目录名称(项目) 不排除路径 -and $_.Name  -notlike $excludeDirList
    Get-ChildItem -s -Depth $Depth -Directory -Exclude $excludeDirList | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $DirName  -and $_.PSPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "") -notlike $excludePathList } | 
                % {
                    trimPsPath($_.PSPath.ToString());
                    $reaultCount = $reaultCount + 1;
                }
    "搜索目录数:" + $reaultCount;
}

#TypeName:Microsoft.PowerShell.Commands.GroupInfo
#
#Name        MemberType Definition
#----        ---------- ----------
#Equals      Method     bool Equals(System.Object obj)
#GetHashCode Method     int GetHashCode()
#GetType     Method     type GetType()
#ToString    Method     string ToString()

#reaultCount       Property   int reaultCount {get;}
#Group       Property   System.Collections.ObjectModel.Collection[psobject] Group {get;}
#Name        Property   string Name {get;}
#Values      Property   System.Collections.ArrayList Values {get;}
