$stlink = "$env:programfiles\stlink-1.3.0-win64"

function Elevate() {
    # Get the ID and security principal of the current user account
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)

    # Check to see if we are currently running "as Administrator"
    if (!$myWindowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)){
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File ""$PSCommandPath""" -verb runas
        exit
    }
}

if($args[0] -eq "uninstall") {
	Elevate
	Remove-Item -Recurse -Force $stlink
}else{
    if (-Not (Test-Path $stlink)){
		Elevate
		Add-Type -AssemblyName System.IO.Compression.FileSystem
		[System.IO.Compression.ZipFile]::ExtractToDirectory("$env:userprofile\Downloads\stlink-1.3.0-win64.zip", "$env:programfiles")
	}else{
        Set-Location "$stlink\bin"
		$FILE = $($args[0]).Replace("\","\\")
        $ADDRESS=" 0x08000000"

        if ($args[1] -eq 'ram') { $ADDRESS=" 0x08001000" }
        if ($args[0] -like '*.hex') { $ADDRESS="" }
		if ($args[0] -like '*.hex') { $FORMAT=" --format ihex" }
		
		#Start-Process ".\st-info.exe" -ArgumentList "--probe" -NoNewWindow -Wait
		#Start-Process ".\st-info.exe" -ArgumentList "--chipid" -NoNewWindow -Wait
		Start-Process ".\st-flash.exe" -ArgumentList "--reset$($FORMAT) write ""$($FILE)""$($ADDRESS)" -NoNewWindow -Wait
	}
}