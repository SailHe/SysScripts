$killProgName="QQProtect"
$waitProgName="TIM"

cd "C:\Program Files\Sandboxie\"

[string]$configPath = Join-Path $HOME "/SandTim-config.txt"
[string]$InputPargramPath = Get-Content $configPath

Start-Process -FilePath "./Start.exe" /terminate -Wait
Start-Process -FilePath "./Start.exe" -ArgumentList $InputPargramPath
Start-Process -FilePath "./Start.exe" -ArgumentList ("C:\Sandbox\"+$env:USERNAME+"\DefaultBox\drive\C\Program Files (x86)\Common Files\Tencent\QQProtect\Bin\QQProtect.exe") -Wait
Start-Process -FilePath "./Start.exe" -ArgumentList ("C:\Sandbox\"+$env:USERNAME+"\DefaultBox\drive\C\Program Files (x86)\Tencent\TIM\Bin\TIM.exe") -Wait

# wait QQ satrting ...
Start-Sleep -Seconds 4
while($true){
    try{
       # ps -Name $waitProgName
       $waitPro = ((ps | ? {$_.name -eq $waitProgName}));
       $killPro = ((ps | ? {$_.name -eq $killProgName}));
       if($waitPro -eq $null){
          "继续";
        }else{
          echo "-----break------"
          $killPro.Kill();
          break;
       }
    }catch{
       "进程" + $waitProgName + "或" + $killPro + "不存在";
    }
}
echo "退出"