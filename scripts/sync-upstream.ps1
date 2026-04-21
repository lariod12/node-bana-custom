# Sync upstream reference repo (shrimbly/node-banana) -> origin/develop
#
# Usage (PowerShell):
#   .\scripts\sync-upstream.ps1            # check + push if updates
#   .\scripts\sync-upstream.ps1 -Check     # only show diff, do not push
#
# If the "reference" remote is missing, the script adds it automatically.

param(
    [switch]$Check
)

$ErrorActionPreference = "Stop"

$ReferenceUrl = "https://github.com/shrimbly/node-banana.git"
$Branch       = "develop"

# Ensure reference remote exists
$remotes = git remote
if ($remotes -notcontains "reference") {
    Write-Host "[+] Adding reference remote: $ReferenceUrl"
    git remote add reference $ReferenceUrl
}

Write-Host "[+] Fetching reference and origin..."
git fetch reference --tags
git fetch origin

$newCommits = (git log --oneline "origin/$Branch..reference/$Branch") | Measure-Object -Line
$count = $newCommits.Lines

if ($count -eq 0) {
    Write-Host "[=] origin/${Branch} is already up-to-date with reference/${Branch}. Nothing to do."
    exit 0
}

Write-Host "[!] reference/${Branch} has $count new commit(s) ahead of origin/${Branch}:"
Write-Host "--------------------------------------------------------------------"
git log --oneline "origin/$Branch..reference/$Branch" | Select-Object -First 30
Write-Host "--------------------------------------------------------------------"

if ($Check) {
    Write-Host "[i] -Check mode: no push performed."
    exit 0
}

Write-Host "[+] Pushing reference/${Branch} -> origin/${Branch} ..."
git push origin "refs/remotes/reference/${Branch}:refs/heads/${Branch}"

Write-Host "[OK] origin/${Branch} synced successfully."
