# �ݹ�Ŀ¼����������(֧������IO) ֧��ƥ�� �ļ���, �ļ�����, Ŀ¼��
# �����ĸ�Ŀ¼�ǽ���ִ��ʱ�Ļ���������Ŀ¼
# https://docs.microsoft.com/zh-cn/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-6
# https://www.pstips.net/accessing-files-and-directories.html

param
(
# [string]$RegularItemName=$(throw "Parameter missing: -RegularItemName RegularItemName"), # ǿ��Ҫ�����
[string]$FileInfo,
[string]$RegularItemName,

[string[]]$includeItemList,
[string[]]$excludeItemList,
[string[]]$excludePathList,

[int]$Depth,
[int]$DisCreateDay,

# �������ļ�����ʱ�Ƿ���ʾ����ϸ�Ľ��
[switch]$isShowDirInfo,

[switch]$isFile,
[switch]$isDir,

# �����ų�ĳЩ��Ŀ����
[switch]$includeTextItem,
[switch]$includeHtmlItem,
[switch]$includeCompressItem,
[switch]$includeEBookItem,
[switch]$includeJsonItem,
# ���ݴ����ʽ
[switch]$includeDataTransmissionItem,
# �ű���ʽ
[switch]$includeScriptItem,
# ���������Ը�ʽ
[switch]$includeCompiledLanguageItem,
# ��ʽ��ʽ
[switch]$includeStyleItem,
# ������Ը�ʽ
[switch]$includeAllCodeItem,

[string]$includeCustomPathType,
# ʹ��Ĭ�ϵİ���·���ļ�
[switch]$includeCustomPath,
# ʹ���Զ���İ���·���ļ�
[string]$includeCustomPathFile,
[switch]$isNotNodePath,
[switch]$isNotCachePath,
[switch]$isNotTempPath
)

# ǿ���ͱ��� �����б�
# ������Ŀ
#[string[]]$includeItemList = $null
# �ų���Ŀ
#[string[]]$excludeItemList = $null
# �ų�·����
#[string[]]$excludePathList = $null

$parMap = @{}
$parMap.Add("RegularItemName", $RegularItemName)
$parMap.Add("FileInfo", $FileInfo)
$parMap.Add("Depth", $Depth)

$contextItemType = [System.IO.FileSystemInfo]

# Ĭ����������ʱ������Ŀ
$DisCreateDayDateTime = $null
$reaultCount = 0;
# ����������·��
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
    # ��ָ�������� ��·���б�ֻ���������͵�·�� �������ȫ��
    if($includeCustomPathType){
        if($parMap.Contains($includeCustomPathType)){
            $includePathList = $parMap[$includeCustomPathType]
        }else{
            Write-Error("ָ��·������[" + $includeCustomPathType + "]������");
            return;
        }
    }
}


if(!$RegularItemName -and !$RegularItemName){
     # ��û�������ʾĬ�������ļ�
    # �ű�Ĭ�ϲ��� (����'ȫ��'Ĭ�ϲ���)
    # �˴�if����ĸĶ�ò�Ʊ�{}�������� ֻ�뵽����취
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
    # $DisCreateDayDateTime > 0 ��ʾ���˱������������һ����Ϊ0���ļ�
    if($DisCreateDay -gt 0){
     #Write-Error("����ʱ��ֻ��ѡȡ֮ǰ��")
     "��ѡ����һ��δ����ʱ��� ��ȷ�ϴ�����������Ŀ"
    }
}

# 2���ݹ� ������Ŀ(�ļ��� �� �ļ�)����Ϊ "*.json" �� *.log(�ɲ���˫����) �ų���Ŀ"nodemon*" �� "*toolkit*"
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

"(P1)��Ŀ¼�ݹ����[" + $Depth + "]ƥ��"
"(P1)������Ŀ����ƥ���б�[" + $includeItemList + "]"
"(P1)�ų���Ŀ����ƥ���б�[" + $excludeItemList + "]"
"(P1)����·���б�[" + $includePathList + "]"
"(P2)�ų�·���б�[" + $excludePathList + "]"
if($DisCreateDay){
    "(P2)�������[" + $DisCreateDay + "]��, ��[" + $DisCreateDayDateTime.ToString("yyyy-MM-dd HH:mm:ss") + "]֮ǰ";
}
"(P2)��Ŀ����������ʽ: [" + $RegularItemName + "]"
# $parMap["FileInfo"] = " " # ���ٵ��Ǹ��ո�
" ->->->->->->->->"
""
$start = Get-Date

function trimPsPath([string]$psPath){
    return $psPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "");
}

if($isDir -and $FileInfo){
    Write-Error("Ŀ¼��֧����������");
} else {
    if($isDir -and $isFile){
        #ʹ�ó�ʼֵ �����ļ���Ŀ¼
    } else {
        if($isDir){
            $contextItemType = [IO.DirectoryInfo]
        } else {
            if($isFile -or $FileInfo){
                $contextItemType = [IO.fileinfo]
                if(($includeCustomPath -or $includeCustomPath -or $includeCustomPathType) -and $Depth){
                    "ָ���˰���·��ʱ�����Եݹ�����޶�"
                }
            }else{
                # δָ�� -> ʹ�ó�ʼֵ �����ļ���Ŀ¼
            }
        }
    }
}

# Get-ChildItem����: Dir; ls(����UNIX����)
# ɸѡ�ļ�/Ŀ¼
# ls -File
# ls -Directory
# | ? $_.GetType().Equals($contextItemType)
$condition = Get-ChildItem -s -Depth $Depth -Include $includeItemList -Exclude $excludeItemList -Path $includePathList | 
             Where-Object {
                 $_ -is $contextItemType -and 
                 $_.Name -like $RegularItemName -and 
                 $_.CreationTime -ge $DisCreateDayDateTime -and 
                 # -Exclude ���ų�Ŀ¼����(��Ŀ) ���ų�·�� -and $_.Name  -notlike $excludeItemList
                 $_.PSPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "") -notlike $excludePathList
             }

#TypeName:Microsoft.PowerShell.Commands.GroupInfo
if($FileInfo){
"ģ��ƥ���ı�����: [" + $FileInfo + "]"
$condition | ForEach-Object { Select-String -Path $_.PSPath -Pattern $FileInfo -Casesensitive -SimpleMatch }  | 
        group Path | % {
            "";
            # �����ײ���'\'�Լ�β�����ļ���
            "Ŀ¼���: " + ($_.Values.Replace($searchContextFullPath, "").Split('\').Length - 2)
            #$_.Name;
            $_.Count.ToString() + "�� ·��λ�� -> " + $_.Values;
            if($isShowDirInfo){
                "____________________________=��·��|ƥ������|ƥ������=____________________________";
                $_.Group;
            }
            "";
            $reaultCount = $reaultCount + 1;
        }
} else {
# % PSPath # �����������������(û���������)���ܲ��û������Լ�$_
$condition | % {
                trimPsPath($_.PSPath.ToString());
                $reaultCount = $reaultCount + 1;
            }
}
"������Ŀ��:" + $reaultCount;

# �������ϼ�ʱ https://www.pstips.net/logging-script-runtime.html
# Measure-Command -Expression {}
$end = Get-Date
Write-Host -ForegroundColor Red ('Total Runtime: ' + ($end - $start).TotalSeconds)
