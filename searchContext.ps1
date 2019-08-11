# �ݹ�Ŀ¼����������(֧������IO) ֧��ƥ�� �ļ���, �ļ�����, Ŀ¼��
# �����ĸ�Ŀ¼�ǽ���ִ��ʱ�Ļ���������Ŀ¼
# https://docs.microsoft.com/zh-cn/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-6
# https://www.pstips.net/accessing-files-and-directories.html

param
(
# [string]$FileName=$(throw "Parameter missing: -FileName FileName"), # ǿ��Ҫ�����
[string]$FileName,
[string]$DirName,
[string]$FileInfo,
[int]$Depth,
[int]$DisCreateDay,
[switch]$isToday,
[switch]$isShowDirInfo,

#�ų�ĳЩ�ļ�������
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

#����һ��ǿ���ͱ��� �����б�
# �ļ�����
[string[]]$includeFileList = $null
# �ų�Ŀ¼��
[string[]]$excludeDirList = $null
# �ų�·����
[string[]]$excludePathList = $null

$parMap = @{}
$parMap.Add("FileName", $FileName)
$parMap.Add("FileInfo", $FileInfo)
$parMap.Add("Depth", $Depth)
#$parMap.Add("OrFile", "1")
$parMap.Add("DisCreateDay", $DisCreateDay)

$contextType = $null

if(!$FileName -and !$DirName){
     # ��û�������ʾĬ�������ļ�
    # �ű�Ĭ�ϲ��� (����'ȫ��'Ĭ�ϲ���)
    # �˴�if����ĸĶ�ò�Ʊ�{}�������� ֻ�뵽����취
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

# $DisCreateDay > 0 ��ʾ���˱������������һ����Ϊ0���ļ�
if($DisCreateDay -gt 0){
 #Write-Error("����ʱ��ֻ��ѡȡ֮ǰ��")
 "��ѡ����һ��δ����ʱ��� ��ȷ�ϴ�����������Ŀ"
}

# 2���ݹ� ������Ŀ(�ļ��� �� �ļ�)����Ϊ "*.json" �� *.log(�ɲ���˫����) �ų���Ŀ"nodemon*" �� "*toolkit*"
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

"��Ŀ¼�ݹ�ƥ��"
"�ݹ����" + $Depth
"�����ļ��б�" + $includeFileList
"ʱ�����" + $DisCreateDay
" ->"

function trimPsPath([string]$psPath){
 return $psPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "");
}

$reaultCount = 0;
$fullPath = (gi .).FullName.ToString()

# Get-ChildItem����: Dir; ls(����UNIX����)
if($FileName){
    "�����ļ�����: [" + $FileName + "]"
    $contextType = [IO.fileinfo]
    if($FileInfo){
        # $parMap["FileInfo"] = " " # ���ٵ��Ǹ��ո�
        "�ı�����: [" + $FileInfo + "]"
        ""
        # -File ����ɸѡ�ļ�
        Get-ChildItem -s -Depth $Depth -File -Include $includeFileList | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $FileName -and $_.CreationTime -gt (Get-Date).AddDays($DisCreateDay) } | 
            ForEach-Object { Select-String -Path $_.PSPath -Pattern $FileInfo -Casesensitive -SimpleMatch }  | 
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
    }else{
        Get-ChildItem -s -Depth $Depth -Include $includeFileList | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $FileName } | 
                # % PSPath # �����������������(û���������)���ܲ��û������Լ�$_
                % {
                    trimPsPath($_.PSPath.ToString());
                    $reaultCount = $reaultCount + 1;
                }
    }
    "�����ļ���:" + $reaultCount;
}
if($DirName){
    "�ų�Ŀ¼�б�" + $excludeDirList
    "�ų�·���б�" + $excludePathList
    "ģ��Ŀ¼����: [" + $DirName + "]"
    ""
    $contextType = [IO.DirectoryInfo]
    # -Exclude ���ų�Ŀ¼����(��Ŀ) ���ų�·�� -and $_.Name  -notlike $excludeDirList
    Get-ChildItem -s -Depth $Depth -Directory -Exclude $excludeDirList | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $DirName  -and $_.PSPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "") -notlike $excludePathList } | 
                % {
                    trimPsPath($_.PSPath.ToString());
                    $reaultCount = $reaultCount + 1;
                }
    "����Ŀ¼��:" + $reaultCount;
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
