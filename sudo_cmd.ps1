#param($c)

#$customCmdMap = @{}
#$customCmdMap.Add("c", $c);
#if([String]::IsNullOrEmpty($c)){
#  $customCmdMap['c'] = "echo helloworld-�봫�������в���:c;";
#}else{
  # DNT
#}
#$command = $customCmdMap['c'] +' pause;'
#Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "//C", "`$command" -Verb runas
# ��������û��Ч�� �޷�����(Ӧ�ÿ���ͨ���ھ��й���ԱȨ�޵�Powershlel��ʹ��cmd����...)

Start-Process -FilePath "C:\Windows\System32\cmd.exe" -Verb runas
