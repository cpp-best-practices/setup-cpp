# if this file cannot run by execution policy, copy this line below and paste into powershell window then drag-drop this script into window and it will run
Set-ExecutionPolicy Bypass -scope Process -Force

# for admin privileges if isn't running as an admin
if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) 
{
	#elevate script and exit current non-elevated runtime
	Start-Process -FilePath 'powershell' -ArgumentList ('-File', $MyInvocation.MyCommand.Source, $args | %{ $_ }) -Verb RunAs
	exit
}

$choice = Read-Host "Press enter to install C++ related tools, ctrl-c to cancel"

if($choice -ne "")
{
	exit
}

$buildNum = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId

if($buildNum -lt 1809)
{
	Write-Error "Your Win10 build number is older than 1809, please upgrade it and try again."
	exit
}
else
{
	Write-Host "Build $buildNum is OK"
}

$cmdName = "winget"
$vclibPath = "$pwd/Microsoft.VCLibs.x64.14.00.Desktop.appx"
$wingetPath = "$pwd/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

if (!(Get-Command $cmdName -errorAction SilentlyContinue))
{
	Write-Error "$cmdName not exists"
	Write-Host "Downloading $cmdName"
	Out-File -FilePath "$pwd/.winget"
	Import-Module BitsTransfer
	Start-BitsTransfer -Source "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Destination $wingetPath
	Start-BitsTransfer -Source "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -Destination $vclibPath
	Write-Host "Installing $cmdName"
	Add-AppxPackage -Path $wingetPath -DependencyPath $vclibPath
	
	# cleanup winget setup files
	Remove-Item $vclibPath
	Remove-Item $wingetPath
}


winget install code --silent --accept-package-agreements --accept-source-agreements
winget install Git.git --silent --accept-package-agreements --accept-source-agreements
winget install python3 --silent --accept-package-agreements --accept-source-agreements
winget install cppcheck --silent --accept-package-agreements --accept-source-agreements

$vsconfig = "{
  `"version`": `"1.0`",`
  `"components`": [
	`"Microsoft.VisualStudio.Component.Roslyn.Compiler`",`
	`"Microsoft.Component.MSBuild`",`
	`"Microsoft.VisualStudio.Component.CoreBuildTools`",`
	`"Microsoft.VisualStudio.Workload.MSBuildTools`",`
	`"Microsoft.VisualStudio.Component.Windows10SDK`",`
	`"Microsoft.VisualStudio.Component.VC.CoreBuildTools`",`
	`"Microsoft.VisualStudio.Component.VC.Tools.x86.x64`",`
	`"Microsoft.VisualStudio.Component.VC.Redist.14.Latest`",`
	`"Microsoft.VisualStudio.Component.Windows10SDK.19041`",`
	`"Microsoft.VisualStudio.Component.VC.CMake.Project`",`
	`"Microsoft.VisualStudio.Component.TestTools.BuildTools`",`
	`"Microsoft.VisualStudio.Component.VC.ATL`",`
	`"Microsoft.VisualStudio.Component.VC.ASAN`",`
	`"Microsoft.VisualStudio.Component.VC.Modules.x86.x64`",`
	`"Microsoft.VisualStudio.Component.TextTemplating`",`
	`"Microsoft.VisualStudio.Component.VC.CoreIde`",`
	`"Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core`",`
	`"Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset`",`
	`"Microsoft.VisualStudio.Workload.VCTools`"`
  ]
}"

Out-File -FilePath $pwd/.vsconfig -InputObject $vsconfig

winget install "Visual Studio Build Tools 2022" --silent --accept-package-agreements --override "--config $pwd/.vsconfig --installPath C:/VS2022-BuildTools --quiet --wait"

Remove-Item "$pwd/.vsconfig"
	
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

code --install-extension ms-vscode.cpptools-extension-pack --install-extension jeff-hykin.better-cpp-syntax --install-extension eamodio.gitlens --install-extension jdinhlife.gruvbox --install-extension xaver.clang-format

pip install --user conan ninja cmake

exit
