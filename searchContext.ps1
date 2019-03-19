# �ݹ�Ŀ¼����������(֧������IO) ֧��ƥ�� �ļ���, �ļ�����, Ŀ¼��
# �����ĸ�Ŀ¼�ǽ���ִ��ʱ�Ļ���������Ŀ¼

param
(
# [string]$FileName=$(throw "Parameter missing: -FileName FileName"), # ǿ��Ҫ�����
[string]$FileName,
[string]$DirName,
[string]$FileInfo
)

$parMap = @{}
$parMap.Add("FileName", $FileName)
$parMap.Add("FileInfo", $FileInfo)

$contextType = $null

if(!$FileName -and !$DirName){
     # ��û�������ʾĬ�������ļ�
    # �ű�Ĭ�ϲ��� (����'ȫ��'Ĭ�ϲ���)
    # �˴�if����ĸĶ�ò�Ʊ�{}�������� ֻ�뵽����취
    $parMap["FileName"] = "*.txt"
}

$FileName = $parMap["FileName"]
$FileInfo = $parMap["FileInfo"]

"��Ŀ¼�ݹ�ƥ�� ->"
if($FileName){
    "�ļ�����: [" + $FileName + "]"
    $contextType = [IO.fileinfo]
    if($FileInfo){
        # $parMap["FileInfo"] = " " # ���ٵ��Ǹ��ո�
        "�ı�����: [" + $FileInfo + "]"
        Get-ChildItem -s | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $FileName } | 
            ForEach-Object { Select-String -Path $_.PSPath -Pattern $FileInfo -Casesensitive -SimpleMatch }  | 
                group Path
    }else{
        Get-ChildItem -s | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $FileName } | 
                # % PSPath # �����������������(û���������)���ܲ��û������Լ�$_
                % {$_.PSPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "")}
    }
}
if($DirName){
    "Ŀ¼����: [" + $DirName + "]"
    $contextType = [IO.DirectoryInfo]
    Get-ChildItem -s | 
        Where-Object { $_.GetType().Equals($contextType) -and $_.Name -like $DirName } | 
                % {$_.PSPath.ToString().Replace("Microsoft.PowerShell.Core\FileSystem::", "")}
}

