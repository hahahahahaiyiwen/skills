param(
    [string]$ResourceMapPath = (Join-Path $PSScriptRoot "..\references\RESOURCE-MAP.yml")
)

$yamlCommand = Get-Command -Name ConvertFrom-Yaml -ErrorAction SilentlyContinue
if (-not $yamlCommand) {
    throw "ConvertFrom-Yaml is not available. Use PowerShell 7+ or install powershell-yaml and adapt this script."
}

$gitCommand = Get-Command -Name git -ErrorAction SilentlyContinue
if (-not $gitCommand) {
    throw "git is not available in PATH."
}

if (-not (Test-Path -Path $ResourceMapPath)) {
    throw "RESOURCE-MAP.yml not found at: $ResourceMapPath"
}

$resourceMap = Get-Content -Path $ResourceMapPath -Raw | ConvertFrom-Yaml
$reposNode = $resourceMap.repos
if ($reposNode -is [System.Collections.IDictionary]) {
    $repoKeys = @($reposNode.Keys)
}
else {
    $repoKeys = @($reposNode.PSObject.Properties.Name)
}

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path

foreach ($repoKey in $repoKeys) {
    if ($reposNode -is [System.Collections.IDictionary]) {
        $repo = $reposNode[$repoKey]
    }
    else {
        $repo = $reposNode.$repoKey
    }

    $repoPathConfig = [string]$repo.path
    $repoGit = [string]$repo.git
    $targetBranch = [string]$repo.target_branch

    if ([string]::IsNullOrWhiteSpace($repoPathConfig) -or [string]::IsNullOrWhiteSpace($repoGit)) {
        throw "Repo '$repoKey' must define both 'path' and 'git' in RESOURCE-MAP.yml."
    }

    if ([string]::IsNullOrWhiteSpace($targetBranch)) {
        throw "Repo '$repoKey' must define 'target_branch' in RESOURCE-MAP.yml."
    }

    if ([System.IO.Path]::IsPathRooted($repoPathConfig)) {
        $repoPath = $repoPathConfig
    }
    else {
        $repoPath = Join-Path $workspaceRoot $repoPathConfig
    }

    if (-not (Test-Path -Path $repoPath)) {
        $repoParent = Split-Path -Parent $repoPath
        if (-not [string]::IsNullOrWhiteSpace($repoParent)) {
            New-Item -ItemType Directory -Force -Path $repoParent | Out-Null
        }

        Write-Host "Cloning '$repoKey' from '$repoGit' (branch '$targetBranch') into '$repoPath'."
        git clone --branch $targetBranch --single-branch $repoGit $repoPath
    }
    else {
        Write-Host "Repo path already exists for '$repoKey': $repoPath"
    }
}

Write-Host "Repository initialization completed."
