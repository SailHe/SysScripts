# 递归目录上下文搜索(支持中文IO) 支持匹配 文件名, 文件内容, 目录名
# 搜索的根目录是进程执行时的环境所处的目录
# https://docs.microsoft.com/zh-cn/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-6
# https://www.pstips.net/accessing-files-and-directories.html

param
(
# [string]$RegularItemName=$(throw "Parameter missing: -RegularItemName RegularItemName"), # 强制要求参数
[string]$FileInfo,
[string]$RegularItemName,

[string[]]$includeItemList,
[string[]]$excludeItemList,
[string[]]$excludePathList,

[int]$Depth,
[int]$DisCreateDay,

# 当搜索文件详情时是否显示更详细的结果
[switch]$isShowDirInfo,

[switch]$isFile,
[switch]$isDir,

# 快速排除某些项目名称
[switch]$includeTextItem,
[switch]$includeHtmlItem,
[switch]$includeCompressItem,
[switch]$includeEBookItem,
[switch]$includeJsonItem,
# 数据传输格式
[switch]$includeDataTransmissionItem,
# 脚本格式
[switch]$includeScriptItem,
# 编译型语言格式
[switch]$includeCompiledLanguageItem,
# 样式格式
[switch]$includeStyleItem,
# 编程语言格式
[switch]$includeAllCodeItem,

[string]$includeCustomPathType,
# 使用默认的包含路径文件
[switch]$includeCustomPath,
# 使用自定义的包含路径文件
[string]$includeCustomPathFile,
[switch]$isNotNodePath,
[switch]$isNotCachePath,
[switch]$isNotTempPath
)

# 强类型变量 名称列表
# 包含项目
#[string[]]$includeItemList = $null
# 排除项目
#[string[]]$excludeItemList = $null
# 排除路径名
#[string[]]$excludePathList = $null

$parMap = @{}
$parMap.Add("RegularItemName", $RegularItemName)
$parMap.Add("FileInfo", $FileInfo)
$parMap.Add("Depth", $Depth)

$contextItemType = [System.IO.FileSystemInfo]

# 默认搜索所有时间点的项目
$DisCreateDayDateTime = $null
$reaultCount = 0;
# 搜索上下文路径
$searchContextFullPath = (gi .).FullName.ToString()

[string]$configPath = Join-Path $HOME "/item-filter-config.txt"
[string[]]$includePathList = $null
if($includeCustomPathFile){
    $configPath = $includeCustomPathFile;
}
if($includeCustomPath){
    $includePathList = Get-Content $configPath
    for($i = 0; $i -lt $includePathList.Count; ++$i){
        $ele = $includePathList[$i];
        $ele = $ele.Split(";");
        [string[]]$trimPath = $ele[1];
        #$trimPath.ToString().LastIndexOf(" ");
        $trimPath = $trimPath.Replace(" ", "").Trim('\t');
        #"---:" + $trimPath
        if($parMap.Contains($ele[0])){
            $parMap[$ele[0]] += $trimPath;
        }else{
            $parMap.Add($ele[0], $trimPath);
        }
        #switch($ele[0]){
        #    "Tutorial" { $trimPath = $ele[1].Trim(' '); break;}
        #}
        $includePathList[$i] = $trimPath
    }
    # 若指定了类型 则路径列表只包含该类型的路径 否则就是全部
    if($includeCustomPathType){
        if($parMap.Contains($includeCustomPathType)){
            $includePathList = $parMap[$includeCustomPathType]
        }else{
            Write-Error("指定路径类型[" + $includeCustomPathType + "]不存在");
            return;
        }
    }
}


if(!$RegularItemName -and !$RegularItemName){
     # 都没有输入表示默认搜索文件
    # 脚本默认参数 (还有'全局'默认参数)
    # 此处if里面的改动貌似被{}给限制了 只想到这个办法
    $parMap["RegularItemName"] = "*"
}

if(!$Depth){
    $parMap["Depth"] = 1
}

$RegularItemName = $parMap["RegularItemName"]
$FileInfo = $parMap["FileInfo"]
$Depth = $parMap["Depth"]

if($DisCreateDay -ne 0){
    $DisCreateDayDateTime = (Get-Date).AddDays($DisCreateDay);
    # $DisCreateDayDateTime > 0 表示将此变量内容输出到一个名为0的文件
    if($DisCreateDay -gt 0){
     #Write-Error("创建时间只能选取之前的")
     "你选择了一个未来的时间点 请确认存在那样的项目"
    }
}

# 2级递归 包含项目(文件夹 或 文件)名称为 "*.json" 和 *.log(可不加双引号) 排除项目"nodemon*" 和 "*toolkit*"
#  Get-ChildItem -s -Depth 2 -Include "*.json" , *.log  -Exclude "nodemon*", "*toolkit*"
if($includeTextItem){
 $includeItemList += "*.txt"
 $includeItemList += "*.log"
 $includeItemList += "*.md"
}
if($includeHtmlItem){
 $includeItemList += "*.html"
}
if($includeCompressItem){
 $includeItemList += "*.zip"
 $includeItemList += "*.7z"
 $includeItemList += "*.r2r"
 $includeItemList += "*.tar"
}
if($includeEBookItem){
 $includeItemList += "*.pdf"
 $includeItemList += "*.mobi"
 $includeItemList += "*.azw3"
 $includeItemList += "*.epub"
 $includeItemList += "*.chm"
}
if($includeAllCodeItem){
 $includeCompiledLanguageItem = $true;
 $includeScriptItem           = $true;
 $includeDataTransmissionItem = $true;
 $includeStyleItem            = $true;
}
if($includeCompiledLanguageItem){
 $includeItemList += "*.c"
 $includeItemList += "*.cpp"
 $includeItemList += "*.h"
 $includeItemList += "*.java"
 $includeItemList += "*.cs"
}
if($includeScriptItem){
 $includeItemList += "*.sql"
 $includeItemList += "*.vbs"
 $includeItemList += "*.js"
 $includeItemList += "*.lua"
 $includeItemList += "*.rb"
 $includeItemList += "*.py"
 $includeItemList += "*.cmd"
 $includeItemList += "*.bat"
 $includeItemList += "*.ps1"
 $includeItemList += "*.sh"
}
if($includeDataTransmissionItem){
 $includeItemList += "*.xml"
 $includeItemList += "*.yml"
 $includeItemList += "*.yaml"
 $includeJsonItem = $true;
}
if($includeJsonItem){
 $includeItemList += "*.json"
}
if($includeStyleItem){
 $includeItemList += "*.css"
 $includeItemList += "*.scss"
}

if($isNotNodePath){
 $excludePathList += "*node_modules*"
}
if($isNotCachePath){
 $excludePathList += "*cache*"
}
if($isNotTempPath){
 $excludePathList += "*temp*"
 $excludePathList += "*tmp*"
}

"(P1)子目录递归深度[" + $Depth + "]匹配"
"(P1)包含项目名称匹配列表[" + $includeItemList + "]"
"(P1)排除项目名称匹配列表[" + $excludeItemList + "]"
"(P1)包含路径列表[" + $includePathList + "]"
"(P2)排除路径列表[" + $excludePathList + "]"
if($DisCreateDay){
    "(P2)距离今日[" + $DisCreateDay + "]天, 于[" + $DisCreateDayDateTime.ToString("yyyy-MM-dd HH:mm:ss") + "]之前";
}
"(P2)项目名称正则表达式: [" + $RegularItemName + "]"
# $parMap["FileInfo"] = " " # 至少得是个空格
" ->->->->->->->->"
""
$start = Get-Date

function trimPsPath([string]$psPath){
    return $psPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "");
}

if($isDir -and $FileInfo){
    Write-Error("目录不支持内容搜索");
} else {
    if($isDir -and $isFile){
        #使用初始值 搜索文件与目录
    } else {
        if($isDir){
            $contextItemType = [IO.DirectoryInfo]
        } else {
            if($isFile -or $FileInfo){
                $contextItemType = [IO.fileinfo]
                if(($includeCustomPath -or $includeCustomPath -or $includeCustomPathType) -and $Depth){
                    "指定了包含路径时将忽略递归深度限定"
                }
            }else{
                # 未指定 -> 使用初始值 搜索文件与目录
            }
        }
    }
}

# Get-ChildItem别名: Dir; ls(来自UNIX家族)
# 筛选文件/目录
# ls -File
# ls -Directory
# | ? $_.GetType().Equals($contextItemType)
$condition = Get-ChildItem -s -Depth $Depth -Include $includeItemList -Exclude $excludeItemList -Path $includePathList | 
             Where-Object {
                 $_ -is $contextItemType -and 
                 $_.Name -like $RegularItemName -and 
                 $_.CreationTime -ge $DisCreateDayDateTime -and 
                 # -Exclude 仅排除目录名称(项目) 不排除路径 -and $_.Name  -notlike $excludeItemList
                 $_.PSPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "") -notlike $excludePathList
             }

#TypeName:Microsoft.PowerShell.Commands.GroupInfo
if($FileInfo){
"模糊匹配文本内容: [" + $FileInfo + "]"
$condition | ForEach-Object { Select-String -Path $_.PSPath -Pattern $FileInfo -Casesensitive -SimpleMatch }  | 
        group Path | % {
            "";
            # 减掉首部的'\'以及尾部的文件名
            "目录深度: " + ($_.Values.Replace($searchContextFullPath, "").Split('\').Length - 2)
            #$_.Name;
            $_.Count.ToString() + "处 路径位于 -> " + $_.Values;
            if($isShowDirInfo){
                "____________________________=子路径|匹配行数|匹配内容=____________________________";
                $_.Group;
            }
            "";
            $reaultCount = $reaultCount + 1;
        }
} else {
# % PSPath # 除非是输出单个属性(没有其余操作)才能不用花括号以及$_
$condition | % {
                trimPsPath($_.PSPath.ToString());
                $reaultCount = $reaultCount + 1;
            }
}
"搜索项目数:" + $reaultCount;

# 无输出诊断计时 https://www.pstips.net/logging-script-runtime.html
# Measure-Command -Expression {}
$end = Get-Date
Write-Host -ForegroundColor Red ('Total Runtime: ' + ($end - $start).TotalSeconds)
