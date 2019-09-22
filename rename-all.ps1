# �Ƚϼ�ª ������� �����滻�ļ���

# �������е�ƥ���ַ��� �����滻���ַ����������� �ļ�����ɸѡ
param($oldtext, $newtext, $filter)

# PowerShell3.0֮ǰ $CurrentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
# �ű��ļ�·��
#$RenameWorkPath = $PSScriptRoot

# PowerShell���̵�ǰ����·��
$RenameWorkPath = (gi .).FullName.ToString()

# �����������
#$Filter = '*.png'
$Filter = $filter
#$newtext = 'newName'
# ������ƹ��ڼ򵥱���en���ܻ�: �޷�������ָ����Ŀ�꣬��Ϊ��Ŀ���ʾ·�����豸���ơ�
#$oldtext = 'oldname'

# $host.UI.WriteErrorLine
Write-Host("��[" + $RenameWorkPath + "]·�������ƴ���[" + $oldtext + "]�Ұ���[" + $filter + "]��������Ŀ������ �滻Ϊ[" + $newtext + "]") -ForegroundColor Red -BackgroundColor Gray
$oP = ($RenameWorkPath + "/*" + $oldtext + "*");
$oP
# Rename-Item �����������ļ��� ��������ɸѡò�Ʋ��󷽱�
$includeItem = ls $oP -Include $Filter -Recurse -File;
pause
$includeItem | out-host -paging
$sure = Read-Host '��ȷ��ִ�������滻 ���滻�˴������Ŀ �޷�����! y/n ����y����ʾȡ��'

if($sure-eq'y'){
    $count = 0;
    $includeItem  | ForEach-Object{
        # Ĭ������� catch ����޷����� Non-Terminating Errors
        # [PowerShell �쳣���� - sparkdev - ����԰](https://www.cnblogs.com/sparkdev/p/8376747.html)
        # [Rename-Item](https://docs.microsoft.com/zh-CN/powershell/module/microsoft.powershell.management/rename-item?view=powershell-6)
        try{
            Rename-Item -Path $_.FullName -NewName $_.Name.Replace($oldtext, $newtext) -ErrorAction Stop;
            $_.FullName
            ++$count;
        }catch{
            Write-Error($PSItem.ToString());
        }
    }
    Write-Output($Path+'������ƥ����ļ�' + $count + '���������ɹ�');
}else{
    "������������ȡ��"
}
