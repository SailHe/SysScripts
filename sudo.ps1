param($c)

$customCmdMap = @{}
# $customCmd = Select-Object -Property c $c
$customCmdMap.Add("c", $c);
# cmdlet Get-Item
# ��ǰִ��·�� ���Ա��ӽ��̻�ȡ ��������ӵ��ͬһ�������Ľ��� �л��û����价��Ҳ��ı�
# �������ڵ�ǰ�������в������� Ҳ��ʹ���Դ��� $pwd 
$env:CURRENT_EXE_FULL_PATH = (gi .).FullName.ToString()
$fullPath = $env:CURRENT_EXE_FULL_PATH

#if($customCmdMap['c'] -eq ''){
if([String]::IsNullOrEmpty($c)){
  $customCmdMap['c'] = "echo �봫�������в���:c;";
}else{
  # $customCmdMap['c'] = "echo helloworld-3;";
}

# Ҳ��֪���Ŀ��� ������ӡ����������ȡȨ��
#$command = 'Restart-Service -Name spooler; '+ $customCmdMap['c'] +'; pause;' 
# ����cd $pwd д�ڴ˴��Ļ������½��Ľ����н��н���
$command = $customCmdMap['c']# + '; pause;'

# Runas�����������û�/��ͨUser�û��Թ���Ա�������ָ������
# runas /user:administrator # administrator Ӧ����һ����Ч���û� Ȼ����������

# �������̵Ļ�����PAC��GUI��ѡ���û� ����ʹ��PIN
# �Թ���Ա������� ����������PowerShell����  -NoNewWindow
Start-Process -FilePath powershell.exe -ArgumentList "-noprofile -NoExit", "-command cd $fullPath; $command" -Verb runas #-WorkingDirectory .


#  ����������Ȩ�����нű�ʱ���û������Ķ�����潫�����仯�� ��ǰĿ¼ ����ǰTEMP�ļ��к�����ӳ��������������Ͽ����ӡ� 
# [Runas�����������û�/��ͨUser�û��Թ���Ա�������ָ������-��ˮ��ʯ���-51CTO����](https://blog.51cto.com/xjsunjie/1979672)
# [Run with elevated permissions UAC - PowerShell - SS64.com](https://ss64.com/ps/syntax-elevate.html)
# [2018-8-23-Processִ��·�� - huangtengxiao](https://xinyuehtx.github.io/post/Process%E6%89%A7%E8%A1%8C%E8%B7%AF%E5%BE%84.html)