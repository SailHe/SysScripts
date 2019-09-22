param
(
[string]$filePath,
[string]$replaceStrReg,
[string]$replaceStr
)

[string]$realFilePath = Resolve-Path($filePath)
[string[]]$resultList = $null

"正则教程: https://www.jianshu.com/p/986d7ca63bdc"
"-replaceStrReg '(这里写正则)'"
"(^\[.*\]) 表示以被中括号包裹的任意字符其中反斜杠是转义中括号的"

#  用 PowerShell 输出中文到剪贴板  https://blog.vichamp.com/2014/07/21/forward-chinese-text-into-clipboard/
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
