# �鿴ָ��������(·��)�����tcp����������� ʵʱ(���1s)ˢ��; ���û�и��������(����ʱ�����������, ����ʱ�����䶯)
# @see
# ԭ��: http://blog.csdn.net/shrekz/article/details/38585417
# HashTable�÷�: https://zhuanlan.zhihu.com/p/31651291
# https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/
# https://ss64.com/ps/

param
(
[switch]$Loop,
[switch]$ShowPath
)

$netLinkMap = @{}
$fullPath = (gi .).FullName.ToString()
# ȥ��������( F:\)ĩβ��'\'
$currentPath = If($fullPath.LastIndexOf('\') -eq $fullPath.Length - 1){$fullPath.Substring(0, $fullPath.Length - 1)} Else {$fullPath}
# ʹ��'/'�޷�ƥ��
$currentPath = ($currentPath + "\*").Replace('\', '\\')
Write-Output("��ѯ"+ $currentPath.Replace('*', '') +"������Ŀ¼������ʹ���������ӽ���ͨ�ŵĽ���")

$pastLinkCount = 0
$currentLinkCount = 0
do{
    # Get-Alias ps; Get-Process
    #Get-Alias ?
    #CommandType     Name                                               Version    Source                                                                          
    #-----------     ----                                               -------    ------                                                                          
    #Alias           % -> ForEach-Object                                                                                                                           
    #Alias           ? -> Where-Object                                                                                                                             
    #Alias           h -> Get-History                                                                                                                              
    #Alias           r -> Invoke-History

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
               # $i: PSCustomObject(ʹ��Select-Object�����Զ������)
               # @see https://www.pstips.net/powershell-create-creating-custom-objects.html
               # https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/netstat
               #  LISTEN���ȴ��κ�Զ��TCP����������
               #  SYN-SENT��������������󣬵ȴ�ƥ����������
               #  SYN-RECEIVED���յ�������һ����������󣬵ȴ���������ȷ�ϡ�
               #  ESTABLISHED��һ���򿪵����ӣ��յ������ݿ��Եݽ����û������������ݴ���״̬��
               #  FIN-WAIT-1���ȴ�Զ��TCP����ֹ���󣬻�ȴ���ֹ�����ȷ�ϡ�
               #  FIN-WAIT-2���ȴ�Զ��TCP����ֹ����
               #  CLOSE-WAIT���ȴ������û���������ֹ����
               #  CLOSING���ȴ�Զ��TCP����ֹ����ȷ�ϡ�
               #  LAST-ACK���ȴ�Զ��TCP��ֹ�����ȷ�ϣ�֮ǰ���͵���ֹ���������ֹ�����ȷ�ϡ�
               #  TIME-WAIT���ȴ��㹻��ʱ�䣬ȷ��Զ��TCP�յ�����ֹ�����ȷ�ϡ�
               #  CLOSED��û���κ�����״̬��
               $i = $_ | Select-Object -Property Protocol, Source, Destination, Mode, Pid, Pname, Ppath
               # Э��; ��Դ����IP��ַ; Ŀ������IP��ַ; TCP���ӵ�״̬{https://tools.ietf.org/html/rfc793}; ����ID; ������
               # https://zh.wikipedia.org/wiki/Ĭ��·��
               # {Source=127.0.0.1:1080; Destination=0.0.0.0:0;} ��Դ�����ǽ���ͨ��IP�Ļػ���ַ��1080�˿�(����), Ŀ�������� ���������� IP ��ַ��
               # {Source=127.0.0.1:2710; Destination=127.0.0.1:1080;} 
               $null, $i.Protocol, $i.Source, $i.Destination, $i.Mode, $i.Pid=  ($_ -split '\s{2,}')
               $i
        } | ? { $_.Pid -eq $id } | % {
                # try{
                #     # Key = Value ����HashTable
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
       "����������дΪ����, ���µ���һ������������Ӽ���"
    }
    # ���ӻ����
    "�仯������: " + $change
    #"����������: " + $newLinkCount
    "ԭ��������: " + $oldLinkCount
    "�ִ���������: " + $currentLinkCount
    "--------------------------------------------------"
   }
   sleep 1
}while($Loop)

"��������: "
$netLinkMap
