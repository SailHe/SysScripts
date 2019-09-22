param($c)

$customCmdMap = @{}
# $customCmd = Select-Object -Property c $c
$customCmdMap.Add("c", $c);
# cmdlet Get-Item
# 当前执行路径 可以被子进程获取 但仅仅是拥有同一个环境的进程 切换用户后其环境也会改变
# 因此最好在当前环境进行参数解析 也可使用自带的 $pwd 
$env:CURRENT_EXE_FULL_PATH = (gi .).FullName.ToString()
$fullPath = $env:CURRENT_EXE_FULL_PATH

#if($customCmdMap['c'] -eq ''){
if([String]::IsNullOrEmpty($c)){
  $customCmdMap['c'] = "echo 请传入命令行参数:c;";
}else{
  # $customCmdMap['c'] = "echo helloworld-3;";
}

# 也不知道哪看的 重启打印机进程来获取权限
#$command = 'Restart-Service -Name spooler; '+ $customCmdMap['c'] +'; pause;' 
# 若把cd $pwd 写在此处的话将在新建的进程中进行解析
$command = $customCmdMap['c']# + '; pause;'

# Runas命令能让域用户/普通User用户以管理员身份运行指定程序
# runas /user:administrator # administrator 应当是一个有效的用户 然后输入密码

# 启动进程的话会在PAC的GUI中选择用户 可以使用PIN
# 以管理员身份运行 动作启动的PowerShell进程  -NoNewWindow
Start-Process -FilePath powershell.exe -ArgumentList "-noprofile -NoExit", "-command cd $fullPath; $command" -Verb runas #-WorkingDirectory .


#  当以提升的权限运行脚本时，用户环境的多个方面将发生变化： 当前目录 ，当前TEMP文件夹和所有映射的驱动器都将断开连接。 
# [Runas命令能让域用户/普通User用户以管理员身份运行指定程序-滴水穿石孙杰-51CTO博客](https://blog.51cto.com/xjsunjie/1979672)
# [Run with elevated permissions UAC - PowerShell - SS64.com](https://ss64.com/ps/syntax-elevate.html)
# [2018-8-23-Process执行路径 - huangtengxiao](https://xinyuehtx.github.io/post/Process%E6%89%A7%E8%A1%8C%E8%B7%AF%E5%BE%84.html)