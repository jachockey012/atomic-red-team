# This PowerShell script was originally created by RedCanary, and later modified by Cyborg Security. 
# The original can be found here: https://github.com/redcanaryco/invoke-atomicredteam/blob/master/Public/Invoke-MalDoc.ps1
#
#--------------------- 
# Maldoc Handler
# This function uses COM objects to emulate the creation and execution of malicious office documents

function Invoke-MalDoc($macro_choice, $office_version, $office_product) {
    
    if ($macro_choice -eq "1"){
        $macro_code = "Sub Test()`n Shell `"cmd.exe calc.exe`" `nEnd Sub"  
    } 
    elseif ($macro_choice -eq "2"){
        $macro_code = "Sub Test()`n Shell `"Powershell.exe calc.exe`" `nEnd Sub"  
    } 
    elseif ($macro_choice -eq "3"){
        $macro_code = "Sub Test()`n Shell `"wmic.exe process call create calc`" `nEnd Sub"  
    } 

    
    if ($office_product -eq "Word") {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$office_version\Word\Security\" -Name 'AccessVBOM' -Value 1
        
        $word = New-Object -ComObject "Word.Application"
        $doc = $word.Documents.Add()
       
        $word.ActiveDocument.VBProject.VBComponents.Add(1)
        $word.VBE.ActiveVBProject.VBComponents.Item("Module1").CodeModule.AddFromString($macro_code)

        $word.Run("Test")
        $doc.Close(0)
    }
    elseif ($office_product -eq "Excel") {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$office_version\Excel\Security\" -Name 'AccessVBOM' -Value 1
        
        $excel = New-Object -ComObject "Excel.Application"
        $excel.Workbooks.Add()
        
        $excel.VBE.ActiveVBProject.VBComponents.Add(1)
        $excel.VBE.ActiveVBProject.VBComponents.Item("Module1").CodeModule.AddFromString($macro_code)
        
        $excel.Run("Test")
        $excel.DisplayAlerts = $False
        $excel.Quit()
    }
    else {
        Write-Host -ForegroundColor Red "$office_product not supported"
    }
}
