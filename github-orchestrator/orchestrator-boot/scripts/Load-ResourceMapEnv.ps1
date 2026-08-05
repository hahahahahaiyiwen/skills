param(
    [string]$ResourceMapPath = (Join-Path $PSScriptRoot "..\references\RESOURCE-MAP.yml"),
    [switch]$Force
)

$yamlCommand = Get-Command -Name ConvertFrom-Yaml -ErrorAction SilentlyContinue
if (-not $yamlCommand) {
    throw "ConvertFrom-Yaml is not available. Use PowerShell 7+ or install powershell-yaml and adapt this script."
}

if (-not (Test-Path -Path $ResourceMapPath)) {
    throw "RESOURCE-MAP.yml not found at: $ResourceMapPath"
}

$resourceMap = Get-Content -Path $ResourceMapPath -Raw | ConvertFrom-Yaml

function Set-EnvValue {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    if (-not $Force -and -not [string]::IsNullOrWhiteSpace((Get-Item -Path "Env:$Name" -ErrorAction SilentlyContinue).Value)) {
        return
    }

    Set-Item -Path "Env:$Name" -Value $Value
}

Set-EnvValue -Name "ADO_ORCH_ORG_NAME" -Value $resourceMap.organization.name
Set-EnvValue -Name "ADO_ORCH_ORG_URL" -Value $resourceMap.organization.url
Set-EnvValue -Name "ADO_ORCH_PROJECT" -Value $resourceMap.organization.project.name
Set-EnvValue -Name "ADO_ORCH_PROJECT_URL" -Value $resourceMap.organization.project.url
$boardNode = $resourceMap.organization.board
if ($boardNode -is [System.Collections.IDictionary]) {
    Set-EnvValue -Name "ADO_ORCH_BOARD_AREA" -Value $boardNode["area"]
    Set-EnvValue -Name "ADO_ORCH_BOARD_ASSIGNED_TO" -Value $boardNode["assigned_to"]
}
else {
    Set-EnvValue -Name "ADO_ORCH_BOARD_AREA" -Value $boardNode.area
    Set-EnvValue -Name "ADO_ORCH_BOARD_ASSIGNED_TO" -Value $boardNode.assigned_to
}

$reposNode = $resourceMap.repos
if ($reposNode -is [System.Collections.IDictionary]) {
    $repoKeys = @($reposNode.Keys)
}
else {
    $repoKeys = @($reposNode.PSObject.Properties.Name)
}

if ($repoKeys.Count -gt 0) {
    Set-EnvValue -Name "ADO_ORCH_DEFAULT_REPO_KEY" -Value $repoKeys[0]
    Set-EnvValue -Name "ADO_ORCH_REPO_KEYS" -Value ($repoKeys -join ",")
}

foreach ($repoKey in $repoKeys) {
    if ($reposNode -is [System.Collections.IDictionary]) {
        $repo = $reposNode[$repoKey]
    }
    else {
        $repo = $reposNode.$repoKey
    }

    Set-EnvValue -Name "ADO_ORCH_REPO_${repoKey}_KEY" -Value $repoKey
    Set-EnvValue -Name "ADO_ORCH_REPO_${repoKey}_PATH" -Value $repo.path
    Set-EnvValue -Name "ADO_ORCH_REPO_${repoKey}_TARGET_BRANCH" -Value $repo.target_branch
    Set-EnvValue -Name "ADO_ORCH_REPO_${repoKey}_GIT" -Value $repo.git
    Set-EnvValue -Name "ADO_ORCH_REPO_${repoKey}_NAME" -Value $repo.ado_repo
}

Write-Host "Loaded RESOURCE-MAP.yml values into environment variables."
