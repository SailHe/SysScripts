param($c)

$customCmdMap = @{}
# $customCmd = Select-Object -Property c $c
$customCmdMap.Add("c", $c);
#if($customCmdMap['c'] -eq ''){
if([String]::IsNullOrEmpty($c)){
  $customCmdMap['c'] = "echo helloworld-请传入命令行参数:c;";
}else{
  # $customCmdMap['c'] = "echo helloworld-3;";
}
$command = 'Restart-Service -Name spooler; '+ $customCmdMap['c'] +' pause;'
Start-Process -FilePath powershell.exe -ArgumentList "-noprofile -command $Command" `
-Verb runas