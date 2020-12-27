# 查看指定条件下(路径)程序的tcp网络连接情况 实时(间隔1s)刷新; 如果没有更新则不输出(增加时会检测出来增量, 减少时不作变动)
# @see
# 原理: http://blog.csdn.net/shrekz/article/details/38585417
# HashTable用法: https://zhuanlan.zhihu.com/p/31651291
# https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/
# https://ss64.com/ps/

param
(
[switch]$Loop,
[switch]$ShowPath
)

$netLinkMap = @{}
$fullPath = (gi .).FullName.ToString()
# 去除驱动器( F:\)末尾的'\'
$currentPath = If($fullPath.LastIndexOf('\') -eq $fullPath.Length - 1){$fullPath.Substring(0, $fullPath.Length - 1)} Else {$fullPath}
# 使用'/'无法匹配
$currentPath = ($currentPath + "\*").Replace('\', '\\')
Write-Output("查询"+ $currentPath.Replace('*', '') +"及其子目录中所有使用网络连接进行通信的进程")

$pastLinkCount = 0
$currentLinkCount = 0
do{
    
    $newLinkCount = 0
    $oldLinkCount = 0
    #ps| Where-Object -FilterScript { $_.Path  -match 'E:\\Program Files Green\\*'} | % -Process
    ps | ? -FilterScript {$_.path  -match $currentPath} | % {
        #Write-Output($_.Path)
        $id = $_.id
        $processName = $_.Name
        $processPath = $_.Path
        #$id
        netstat -ano | ForEach-Object -Process {
               #Write-Output($_.Length)
               # Write-Output($_.GetType())
               # $i: PSCustomObject(使用Select-Object创建自定义对象)
               # @see https://www.pstips.net/powershell-create-creating-custom-objects.html
               # https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/netstat
               #  LISTEN：等待任何远程TCP的连接请求。
               #  SYN-SENT：发送连接请求后，等待匹配连接请求。
               #  SYN-RECEIVED：收到并发送一个连接请求后，等待连接请求确认。
               #  ESTABLISHED：一个打开的连接，收到的数据可以递交给用户，正常的数据传输状态。
               #  FIN-WAIT-1：等待远程TCP的终止请求，或等待终止请求的确认。
               #  FIN-WAIT-2：等待远程TCP的终止请求。
               #  CLOSE-WAIT：等待本地用户的连接终止请求。
               #  CLOSING：等待远程TCP的终止请求确认。
               #  LAST-ACK：等待远程TCP终止请求的确认，之前发送的终止请求包含终止请求的确认。
               #  TIME-WAIT：等待足够的时间，确保远程TCP收到了终止请求的确认。
               #  CLOSED：没有任何连接状态。
               $i = $_ | Select-Object -Property Protocol, Source, Destination, Mode, Pid, Pname, Ppath
               # 协议; 本源网络IP地址; 目标网络IP地址; TCP连接的状态{https://tools.ietf.org/html/rfc793}; 进程ID; 进程名
               # https://zh.wikipedia.org/wiki/默认路由
               # {Source=127.0.0.1:1080; Destination=0.0.0.0:0;} 本源网络是进程通信IP的回环地址的1080端口(监听), 目标网络是 本机的所有 IP 地址。
               # {Source=127.0.0.1:2710; Destination=127.0.0.1:1080;} 
               $null, $i.Protocol, $i.Source, $i.Destination, $i.Mode, $i.Pid=  ($_ -split '\s{2,}')
               $i
        } | ? { $_.Pid -eq $id } | % {
                # try{
                #     # Key = Value 附加HashTable
                #     $netLinkMap += @{ $_.Destination = $_.Source }
                #     ++$newLinkCount
                # 
                #     # output
                #     $_.Pname = $processName
                #     $_.Ppath = $processPath
                #     $_
                # }
                # catch {++$oldLinkCount}
                if($netLinkMap.ContainsKey($_.Destination)){
                    ++$oldLinkCount
                } else{
                    $netLinkMap.Add($_.Destination, $_.Source)
                    ++$newLinkCount
                    # output
                    $_.Pname = $processName
                    $_.Ppath = $processPath
                    $_
                }
            }
   }
   $pastLinkCount = $currentLinkCount
   $currentLinkCount = ($oldLinkCount + $newLinkCount)
   $change = $currentLinkCount - $pastLinkCount
   if($change -ne 0) {
    if($change -lt 0){
       "将上述语句改写为方法, 重新调用一次输出现有连接即可"
    }
    # 增加或减少
    "变化连接数: " + $change
    #"新增连接数: " + $newLinkCount
    "原有连接数: " + $oldLinkCount
    "现存总连接数: " + $currentLinkCount
    "--------------------------------------------------"
   }
   sleep 1
}while($Loop)

"所有连接: "
$netLinkMap
