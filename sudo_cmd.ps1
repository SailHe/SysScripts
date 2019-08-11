#param($c)

#$customCmdMap = @{}
#$customCmdMap.Add("c", $c);
#if([String]::IsNullOrEmpty($c)){
#  $customCmdMap['c'] = "echo helloworld-请传入命令行参数:c;";
#}else{
  # DNT
#}
#$command = $customCmdMap['c'] +' pause;'
#Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "//C", "`$command" -Verb runas
# 上面的语句没有效果 无法传参(应该可以通过在具有管理员权限的Powershlel中使用cmd命令...)

Start-Process -FilePath "C:\Windows\System32\cmd.exe" -Verb runas
