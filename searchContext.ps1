# �ݹ�Ŀ¼����������(֧������IO) ֧��ƥ�� �ļ���, �ļ�����, Ŀ¼��
# �����ĸ�Ŀ¼�ǽ���ִ��ʱ�Ļ���������Ŀ¼
# https://docs.microsoft.com/zh-cn/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-6
# https://www.pstips.net/accessing-files-and-directories.html

param
(
# [string]$RegularItemName=$(throw "Parameter missing: -RegularItemName RegularItemName"), # ǿ��Ҫ�����
[string]$RegularItemName,
[string]$FileInfo,

[string[]]$includeitemList,
[string[]]$excludeItemList,
[string[]]$excludePathList,

[int]$Depth,
[int]$DisCreateDay,
# �Ƿ������������Ŀ
[switch]$isToday,

# �������ļ�����ʱ�Ƿ���ʾ����ϸ�Ľ��
[switch]$isShowDirInfo,

[switch]$isFile,
[switch]$isDir,

# �����ų�ĳЩ��Ŀ����
[switch]$includeTextItem,
[switch]$includeHtmlItem,
[switch]$includeMarkdownItem,
[switch]$includeLogItem,
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

[switch]$isNotNodePath,
[switch]$isNotCachePath,
[switch]$isNotTempPath
)

# ǿ���ͱ��� �����б�
# ������Ŀ
#[string[]]$includeitemList = $null
# �ų���Ŀ
#[string[]]$excludeItemList = $null
# �ų�·����
#[string[]]$excludePathList = $null

$parMap = @{}
$parMap.Add("RegularItemName", $RegularItemName)
$parMap.Add("FileInfo", $FileInfo)
$parMap.Add("Depth", $Depth)
$parMap.Add("DisCreateDay", $DisCreateDay)

$contextItemType = [System.IO.FileSystemInfo]

$reaultCount = 0;
$fullPath = (gi .).FullName.ToString()


if(!$RegularItemName -and !$RegularItemName){
     # ��û�������ʾĬ�������ļ�
    # �ű�Ĭ�ϲ��� (����'ȫ��'Ĭ�ϲ���)
    # �˴�if����ĸĶ�ò�Ʊ�{}�������� ֻ�뵽����취
    $parMap["RegularItemName"] = "*"
}

if(!$Depth){
    $parMap["Depth"] = 1
}

if(!$DisCreateDay -and !$isToday){
    $parMap["DisCreateDay"] = -365
}

$RegularItemName = $parMap["RegularItemName"]
$FileInfo = $parMap["FileInfo"]
$Depth = $parMap["Depth"]
$DisCreateDay = $parMap["DisCreateDay"]

# $DisCreateDay > 0 ��ʾ���˱������������һ����Ϊ0���ļ�
if($DisCreateDay -gt 0){
 #Write-Error("����ʱ��ֻ��ѡȡ֮ǰ��")
 "��ѡ����һ��δ����ʱ��� ��ȷ�ϴ�����������Ŀ"
}

# 2���ݹ� ������Ŀ(�ļ��� �� �ļ�)����Ϊ "*.json" �� *.log(�ɲ���˫����) �ų���Ŀ"nodemon*" �� "*toolkit*"
#  Get-ChildItem -s -Depth 2 -Include "*.json" , *.log  -Exclude "nodemon*", "*toolkit*"
if($includeTextItem){
 $includeitemList += "*.txt"
}
if($includeHtmlItem){
 $includeitemList += "*.html"
}
if($includeMarkdownItem){
 $includeitemList += "*.md"
}
if($includeLogItem){
 $includeitemList += "*.log"
}
if($includeJsonItem){
 $includeitemList += "*.json"
}
if($includeAllCodeItem){
 $includeCompiledLanguageItem = $true;
 $includeScriptItem           = $true;
 $includeDataTransmissionItem = $true;
 $includeStyleItem            = $true;
}
if($includeCompiledLanguageItem){
 $includeitemList += "*.c"
 $includeitemList += "*.cpp"
 $includeitemList += "*.h"
 $includeitemList += "*.java"
 $includeitemList += "*.cs"
}
if($includeScriptItem){
 $includeitemList += "*.sql"
 $includeitemList += "*.vbs"
 $includeitemList += "*.js"
 $includeitemList += "*.lua"
 $includeitemList += "*.rb"
 $includeitemList += "*.py"
 $includeitemList += "*.cmd"
 $includeitemList += "*.bat"
 $includeitemList += "*.ps1"
 $includeitemList += "*.sh"
}
if($includeDataTransmissionItem){
 $includeitemList += "*.xml"
 $includeitemList += "*.yml"
 $includeitemList += "*.yaml"
}
if($includeStyleItem){
 $includeitemList += "*.css"
 $includeitemList += "*.scss"
 $includeitemList += "*.sacss"
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

"(P1)��Ŀ¼�ݹ����" + $Depth + "ƥ��"
"(P1)������Ŀ����ƥ���б�" + $includeitemList
"(P1)�ų���Ŀ����ƥ���б�" + $excludeItemList
"(P2)�������" + $DisCreateDay + "��"
"(P2)�ų�·���б�" + $excludePathList
"(P2)��Ŀ����������ʽ: [" + $RegularItemName + "]"
# $parMap["FileInfo"] = " " # ���ٵ��Ǹ��ո�
" ->->->->->->->->"
""

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
            }else{
                #ʹ�ó�ʼֵ �����ļ���Ŀ¼
            }
        }
    }
}

# Get-ChildItem����: Dir; ls(����UNIX����)
# ɸѡ�ļ�/Ŀ¼
# ls -File
# ls -Directory
# | ? $_.GetType().Equals($contextItemType)
$condition = Get-ChildItem -s -Depth $Depth -Include $includeitemList -Exclude $excludeItemList | 
             Where-Object {
                 $_ -is $contextItemType -and 
                 $_.Name -like $RegularItemName -and 
                 $_.CreationTime -gt (Get-Date).AddDays($DisCreateDay) -and 
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
            "Ŀ¼���: " + ($_.Values.Replace($fullPath, "").Split('\').Length - 2)
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
