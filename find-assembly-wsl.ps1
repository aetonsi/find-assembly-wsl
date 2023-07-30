#!/usr/bin/env pwsh
#Requires -RunAsAdministrator


function Find-AssemblyInWsl ([string]$Name, [switch]$CaseSensitive, [switch]$AddType) {
  if (!$IsLinux) { return $null }

  if ($CaseSensitive) { $i = @() } else { $i = @('--ignore-case') }
  & which apt-file >$null || sudo apt install apt-file -y >$null
  & sudo apt-file update >$null
  $dlls = & apt-file search @i $Name
  if (!$dlls) { return $false }

  [array]::Reverse($dlls)
  foreach ($dll in $dlls) {
    $dll = ($dll -split ': ')[1]
    if (([System.Io.Path]::GetExtension($dll) -eq '.dll') -and (Test-Path $dll)) {
      # found
      break
    }
    $dll = $false
  }

  if ($AddType) {
    return (Add-Type -Path $dll)
  } else {
    return $dll
  }
}

Find-AssemblyInWsl @args