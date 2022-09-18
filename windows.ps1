# if this file cannot run by execution policy, copy this line below and paste into powershell window then drag-drop this script into window and it will run
Set-ExecutionPolicy RemoteSigned -scope Process -Force

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
$arch = ({x64}, {x86})[![Environment]::Is64BitOperatingSystem]
$wingetUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.1.12653/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$wingetLicUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.1.12653/9c0fe2ce7f8e410eb4a8f417de74517e_License1.xml"
$vclibUrl = "https://aka.ms/Microsoft.VCLibs.$arch.14.00.Desktop.appx"
$uixamlUrl = "https://globalcdn.nuget.org/packages/microsoft.ui.xaml.2.7.1.nupkg"

$uixamlFolder = "Microsoft.UI.Xaml.2.7.1.nupkg"
$uixamlZip = "Microsoft.UI.Xaml.2.7.1.nupkg.zip"

$vclibPath = "$pwd/Microsoft.VCLibs.14.00.Desktop.appx"
$uixamlPath = "$pwd/Microsoft.UI.Xaml.2.7.1.nupkg\tools\AppX\$arch\Release\Microsoft.UI.Xaml.2.7.appx"
$wingetPath = "$pwd/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$wingetLicPath = "$pwd/9c0fe2ce7f8e410eb4a8f417de74517e_License1.xml"

if (!(Get-Command $cmdName -errorAction SilentlyContinue))
{
	Write-Error "$cmdName not exists"
	Write-Host "Downloading $cmdName"
	Import-Module BitsTransfer
	Start-BitsTransfer -Source $wingetUrl -Destination $wingetPath
	Start-BitsTransfer -Source $wingetLicUrl -Destination $wingetLicPath
	Start-BitsTransfer -Source $vclibUrl -Destination $vclibPath
	Start-BitsTransfer -Source $uixamlUrl -Destination $uixamlZip
	Expand-Archive $uixamlZip
	Write-Host "Installing $cmdName"
	Add-AppxProvisionedPackage -Online -PackagePath $vclibPath -SkipLicense
	Add-AppxProvisionedPackage -Online -PackagePath $uixamlPath -SkipLicense
	Add-AppxProvisionedPackage -Online -PackagePath $wingetPath -LicensePath $wingetLicPath # -DependencyPackagePath $uixamlPath -DependencyPackagePath $vclibPath
	
	# cleanup winget setup files
	Remove-Item $vclibPath
	Remove-Item $wingetPath
	Remove-Item $wingetLicPath
	Remove-Item $uixamlZip
	Remove-Item $uixamlFolder -Recurse
}

Start-Sleep -s 10

[System.Environment]::SetEnvironmentVariable('Path', "$env:localappdata\Microsoft\WindowsApps;" + [System.Environment]::GetEnvironmentVariable("Path","User") ,[System.EnvironmentVariableTarget]::User)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

winget install Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements
winget install Git.git --silent --accept-package-agreements --accept-source-agreements
winget install Python.Python.3.9 --silent --accept-package-agreements --accept-source-agreements
winget install Kitware.CMake --silent --accept-package-agreements --accept-source-agreements
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
	`"Microsoft.VisualStudio.Component.VC.Llvm.Clang`",`
	`"Microsoft.VisualStudio.Workload.VCTools`"`
  ]
}"

Out-File -FilePath $pwd/.vsconfig -InputObject $vsconfig

winget install "Visual Studio Build Tools 2022" --silent --accept-package-agreements --override "--config $pwd/.vsconfig --installPath C:/VS2022-BuildTools --quiet --wait"

Remove-Item "$pwd/.vsconfig"

[System.Environment]::SetEnvironmentVariable('Path', "C:\VS2022-BuildTools\VC\Tools\Llvm\bin;$env:programfiles\CMake\bin;$env:localappdata\Programs\Microsoft VS Code;$env:localappdata\Programs\Microsoft VS Code\bin;$env:localappdata\Programs\Python\Python39\Scripts\;$env:localappdata\Programs\Python\Python39\;" + [System.Environment]::GetEnvironmentVariable("Path","User") ,[System.EnvironmentVariableTarget]::User)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Start-Sleep -s 10

code.cmd --install-extension ms-vscode.cpptools-extension-pack --install-extension yuzuhakuon.vscode-cpp-project --install-extension jeff-hykin.better-cpp-syntax --install-extension eamodio.gitlens --install-extension jdinhlife.gruvbox --install-extension xaver.clang-format

pip install --user conan ninja cmake

exit

# SIG # Begin signature block
# MIIbzgYJKoZIhvcNAQcCoIIbvzCCG7sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtd8BOSl2kh5k/6NjTgAXxXTT
# pMagghZBMIIDDDCCAfSgAwIBAgIQGHZfo+K2bKZBW2L4o9kWszANBgkqhkiG9w0B
# AQsFADAeMRwwGgYDVQQDDBNnaXRodWIuY29tL21ndWx1ZGFnMB4XDTIyMDcwODEx
# MTcwNloXDTIzMDcwODExMzcwNlowHjEcMBoGA1UEAwwTZ2l0aHViLmNvbS9tZ3Vs
# dWRhZzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANTD6/cilzVVfCB2
# ZiFWI6T+TKzm6t0pdkDkXTxeI9chBRX1DdwPyoXr8RBo/v3g1NhhOld+qlkRQKRj
# p7XUHdZzdrAADD3p4b1uvUPXvAg1XTnS5/ulTkexQcEmZxUS6sJ4V1SAASxP2iSW
# zQ7t5ks/9e8sy2thYRnqThDp9ALqvNNDb0YS8lNYLL+EueXdICwENA5YH45YoHPc
# ROVs+qOrAjP5AhBnwrfjKl4A/IQz6egxWuHW1CElMhUWWri4s5mBzyGWsBxP6oOw
# cZKjbcTDV0GTIwG4OoFVQKyzbHGDjdL59Cc+crYqqFPVmtHM+wtYWTKw2ENIv9lh
# vT9bHJ0CAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBR5rn6WFkIK/ypnIA6P7E/WNqVfhDANBgkqhkiG9w0BAQsF
# AAOCAQEAxzXJZscJNKNnWsgs2waMyZ2YBcmSBJrIu2UaZv5Jb5ly0M4CQadeYK/w
# Ec1Ne9xfA1gelC6TlY4JXTP5EKXQa5ArkEXNZSbB9fVio7WdAxg6fSXERRvKO57m
# czzUFfPtK1bFyIt6HsyuEVMblPz/vcyVFR9OE1JTNKRLQ0fq6pLidXeYLiuKSHB7
# N8pTu7OhsI07kYIniL22Xy4oFKhe8BQ5xuBGNfmuBmDfTwGg0HK9mCufINHLNT+l
# Utlc4z+baJQsGlOI9T0Z5GidRTMY1QEQYn/M/u6atOtE0EIJ5LuKIYOTobrWSKwM
# tz4EpYg+Zcf1Er/Blies38j7NJiD1jCCBbEwggSZoAMCAQICEAEkCvseOAuKFvFL
# cZ3008AwDQYJKoZIhvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERp
# Z2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMb
# RGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTIyMDYwOTAwMDAwMFoXDTMx
# MTEwOTIzNTk1OVowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IElu
# YzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQg
# VHJ1c3RlZCBSb290IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# v+aQc2jeu+RdSjwwIjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/Mb
# pDgW61bGl20dq7J58soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlq
# czKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxb
# Grzryc/NrDRAX7F6Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcva
# k17cjo+A2raRmECQecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sE
# cypukQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ck
# XEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA
# 5EUlibaaRBkrfsCUtNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFj
# GESVGnZifvaAsPvoZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+
# Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotP
# wtZFX50g/KEexcCPorF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCAV4wggFaMA8G
# A1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8G
# A1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjAT
# BgNVHSUEDDAKBggrBgEFBQcDCDB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDBF
# BgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCG
# SAGG/WwHATANBgkqhkiG9w0BAQwFAAOCAQEAmhYCpQHvgfsNtFiyeK2oIxnZczfa
# YJ5R18v4L0C5ox98QE4zPpA854kBdYXoYnsdVuBxut5exje8eVxiAE34SXpRTQYy
# 88XSAConIOqJLhU54Cw++HV8LIJBYTUPI9DtNZXSiJUpQ8vgplgQfFOOn0XJIDcU
# wO0Zun53OdJUlsemEd80M/Z1UkJLHJ2NltWVbEcSFCRfJkH6Gka93rDlkUcDrBgI
# y8vbZol/K5xlv743Tr4t851Kw8zMR17IlZWt0cu7KgYg+T9y6jbrRXKSeil7FAM8
# +03WSHF6EBGKCHTNbBsEXNKKlQN2UVBT1i73SkbDrhAscUywh7YnN0RgRDCCBq4w
# ggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4X
# DTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAV
# BgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVk
# IEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5M
# om2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE
# 2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWN
# lCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFo
# bjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhN
# ef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3Vu
# JyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtz
# Q87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4O
# uGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5
# sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm
# 4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIz
# tM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6
# FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qY
# rhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYB
# BQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20w
# QQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZ
# MBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmO
# wJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H
# 6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/
# R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzv
# qLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/ae
# sXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdm
# kfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3
# EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh
# 3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA
# 3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8
# BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsf
# gPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggbGMIIErqADAgECAhAKekqI
# nsmZQpAGYzhNhpedMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBH
# NCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjIwMzI5MDAwMDAw
# WhcNMzMwMzE0MjM1OTU5WjBMMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNl
# cnQsIEluYy4xJDAiBgNVBAMTG0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIyIC0gMjCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALkqliOmXLxf1knwFYIY9DPu
# zFxs4+AlLtIx5DxArvurxON4XX5cNur1JY1Do4HrOGP5PIhp3jzSMFENMQe6Rm7p
# o0tI6IlBfw2y1vmE8Zg+C78KhBJxbKFiJgHTzsNs/aw7ftwqHKm9MMYW2Nq867Lx
# g9GfzQnFuUFqRUIjQVr4YNNlLD5+Xr2Wp/D8sfT0KM9CeR87x5MHaGjlRDRSXw9Q
# 3tRZLER0wDJHGVvimC6P0Mo//8ZnzzyTlU6E6XYYmJkRFMUrDKAz200kheiClOEv
# A+5/hQLJhuHVGBS3BEXz4Di9or16cZjsFef9LuzSmwCKrB2NO4Bo/tBZmCbO4O2u
# fyguwp7gC0vICNEyu4P6IzzZ/9KMu/dDI9/nw1oFYn5wLOUrsj1j6siugSBrQ4nI
# fl+wGt0ZvZ90QQqvuY4J03ShL7BUdsGQT5TshmH/2xEvkgMwzjC3iw9dRLNDHSNQ
# zZHXL537/M2xwafEDsTvQD4ZOgLUMalpoEn5deGb6GjkagyP6+SxIXuGZ1h+fx/o
# K+QUshbWgaHK2jCQa+5vdcCwNiayCDv/vb5/bBMY38ZtpHlJrYt/YYcFaPfUcONC
# leieu5tLsuK2QT3nr6caKMmtYbCgQRgZTu1Hm2GV7T4LYVrqPnqYklHNP8lE54CL
# KUJy93my3YTqJ+7+fXprAgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgG
# BmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxq
# II+eyG8wHQYDVR0OBBYEFI1kt4kh/lZYRIRhp+pvHDaP3a8NMFoGA1UdHwRTMFEw
# T6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRH
# NFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGD
# MIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYB
# BQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0
# ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQEL
# BQADggIBAA0tI3Sm0fX46kuZPwHk9gzkrxad2bOMl4IpnENvAS2rOLVwEb+EGYs/
# XeWGT76TOt4qOVo5TtiEWaW8G5iq6Gzv0UhpGThbz4k5HXBw2U7fIyJs1d/2Wcuh
# wupMdsqh3KErlribVakaa33R9QIJT4LWpXOIxJiA3+5JlbezzMWn7g7h7x44ip/v
# EckxSli23zh8y/pc9+RTv24KfH7X3pjVKWWJD6KcwGX0ASJlx+pedKZbNZJQfPQX
# podkTz5GiRZjIGvL8nvQNeNKcEiptucdYL0EIhUlcAZyqUQ7aUcR0+7px6A+TxC5
# MDbk86ppCaiLfmSiZZQR+24y8fW7OK3NwJMR1TJ4Sks3KkzzXNy2hcC7cDBVeNaY
# /lRtf3GpSBp43UZ3Lht6wDOK+EoojBKoc88t+dMj8p4Z4A2UKKDr2xpRoJWCjihr
# pM6ddt6pc6pIallDrl/q+A8GQp3fBmiW/iqgdFtjZt5rLLh4qk1wbfAs8QcVfjW0
# 5rUMopml1xVrNQ6F1uAszOAMJLh8UgsemXzvyMjFjFhpr6s94c/MfRWuFL+Kcd/K
# l7HYR+ocheBFThIcFClYzG/Tf8u+wQ5KbyCcrtlzMlkI5y2SoRoR/jKYpl0rl+CL
# 05zMbbUNrkdjOEcXW28T2moQbh9Jt0RbtAgKh1pZBHYRoad3AhMcMYIE9zCCBPMC
# AQEwMjAeMRwwGgYDVQQDDBNnaXRodWIuY29tL21ndWx1ZGFnAhAYdl+j4rZspkFb
# Yvij2RazMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTx2FmOp2oDlGSAuRErM54IDZuYkTANBgkq
# hkiG9w0BAQEFAASCAQApt3xc//N3EBdBa50ZQf9B7lcNz6ohd6VAy5g4CT0N3Xir
# We5h2ZE8kxHLmZbbLdlo6X4Hd4dWgsJayi+jdpCIu8SE+bFlpDB0unc45i/xq/zl
# KyFzSQG1rloNJLRMm1Rvy18pXAKp/Ga6Y1w9lItV7rr710ZiWBTJco7XWjtBtBB0
# kaHJTLSZ2DSrhEtx9gZGbIEJRBhfZB6DI2jRBXPxzBiYSKxHrN0bqA4VpF4v474J
# tOsXmS5fRFByD1Nl2v6RCnb1rILFHB3XznPyxw0B961kBNlySeIVxhTYpfRNdvVa
# dYsF7HZcFGQjCWTObiwHz/J16p3P4+wW1WhQxqTBoYIDIDCCAxwGCSqGSIb3DQEJ
# BjGCAw0wggMJAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0
# LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hB
# MjU2IFRpbWVTdGFtcGluZyBDQQIQCnpKiJ7JmUKQBmM4TYaXnTANBglghkgBZQME
# AgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8X
# DTIyMDcwODExMjkzMlowLwYJKoZIhvcNAQkEMSIEIAOlzisjog6lfYX191tFj8/b
# r5MNn13JHK5fr5D4/GtrMA0GCSqGSIb3DQEBAQUABIICAA6aLF66sGhSOfsu0ySh
# txuHzhMNb85xyG95EmNasABWlSbf399FFNrAi3W//UvMt8+KlV8bs3lqkeC/ux5X
# IIFMKBxlB7FdwQrHWqyD8LWMarGqk2M0ZzzrtzUXVEgHzIlhVTf6ZOe+oA6vg69h
# vWcFdcnwL2jciImD6Gdos40qX/znS1fW5Ks4v0HU7V38Ba4mROp3Odzcx0G22Tss
# FevAiu2Uk+ISpMWPkoUIdzt3U+TE3YZ8yKw97OWaULD6DYGlRRlmXeBvoYkZ1EYi
# /p9HEaAqE9RkFEWtOdfn5+CB/D81MgAmRLdSUQKyE/JSS8gvMP7uV2vAmJyVLbWH
# wcC642TuOrHyWJQivJHVr+D2nU3Cpa6zGl3b4Eny5DASVsNHrFt0lah12Q8N/4SW
# AI7jWQUTxEkGr63FW14WjAS3jfsP5DL0c10neoZRZ2JB+tokif2YbT6ixftAStLn
# XTZm38Uf1XBHVG2c/rzAUqBU7bbrpaxMoM+NMRFKgqrpLxYfeccPNRtGpmJKKlbM
# /oUb06zLLfbe8LWlNcja/uVhbGqnaoCIQ9Mq2C5reLkBE163AALVYSilmxG9ukVw
# 22LJajUSNGJex0cG6qNbbP/NJZs/Mp1LCCxPCHmTJlN1uzouYFLnk/A1l5Z/uNNo
# 3GNj6G3vFT9grYz1IE6Ja9zl
# SIG # End signature block
