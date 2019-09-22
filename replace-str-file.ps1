param
(
[string]$filePath,
[string]$replaceStrReg,
[string]$replaceStr
)

[string]$realFilePath = Resolve-Path($filePath)
[string[]]$resultList = $null

"����̳�: https://www.jianshu.com/p/986d7ca63bdc"
"-replaceStrReg '(����д����)'"
"(^\[.*\]) ��ʾ�Ա������Ű����������ַ����з�б����ת�������ŵ�"

#  �� PowerShell ������ĵ�������  https://blog.vichamp.com/2014/07/21/forward-chinese-text-into-clipboard/
$OutputEncoding = [Console]::OutputEncoding

$resultList = Get-Content $realFilePath
for($i = 0; $i -lt $resultList.Count; ++$i){
    $ele = $resultList[$i];
    # https://www.pstips.net/regex-replace-string.html
    $ele = $ele -replace $replaceStrReg, $replaceStr;
    $resultList[$i] = $ele;
}
#Set-Clipboard $resultList
$resultList | clip.exe
