#!/usr/bin/env pwsh

# Deploy from Network Isolation Bastion
#
# Requires:
#   choco[latey]

param (
  $subscription,
  $location,
  $environment,
  $directory,
  $repository   = 'azure/gpt-rag',  # without .git suffix / extension
  $branch
)

$paramNames = @(
  'repository',
  'branch',
  'directory',
  'subscription',
  'location',
  'environment'
)

# Ensure required parameters set
$paramUserPromptPrefix = "Enter provisioned Environment's "
$paramsRequiredUserPromptSuffixes = [ordered]@{
  repository   = 'Project Template Repository'
  subscription = 'Azure Subscription Name or Id'
  location     = "Azure Location / Region"
  environment  = "Name"
}
foreach ($name in $paramsRequiredUserPromptSuffixes.Keys) {
  while (!(Get-Variable -ValueOnly $name)) {
    Set-Variable $name (Read-Host "$paramUserPromptPrefix $($paramsRequiredUserPromptSuffixes[$name])")
  }
}

if (!$directory) {
  $directory = Split-Path -Leaf $repository
  #                       -LeafBase not supported by PowerShell version in Bastion image
  # $directory = Split-Path -LeafBase $repository
}


# Output configuration
$paramNamesWidth = ($paramNames | Measure-Object -Maximum -Property Length).Maximum
''
foreach ($name in $paramNames) {
  "$($name.PadRight($paramNamesWidth)) = $(Get-Variable -ValueOnly $name)"
}
''


# Upgrade & Install dependencies

# chocolatey upgrade
choco upgrade chocolatey -y
choco --version

# azd & pwsh install/upgrade
choco upgrade azd pwsh   -y
# pwsh required for deployment scripts

# git install/upgrade for debugging
#choco upgrade git       -y

# Refresh to run azd & pwsh without starting new session
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv
azd    version
pwsh --version


# Project

# Directory

## Create & Enter
mkdir "$directory" -ea 0
# `-ea 0`  ≈  Linux `mkdir -p`

cd    "$directory"

## Initialize
$azdInitCommand = "azd init -t '$repository'  -s '$subscription'  -l '$location'  -e '$environment'"
if ($branch) {
  $azdInitCommand += "  -b '$branch'"
}
Invoke-Expression $azdInitCommand


## Authenticate with Azure
azd auth login

## Pull Environment from Azure
azd env refresh

## Package locally
azd package

## Deploy to Azure
'y' |  azd deploy