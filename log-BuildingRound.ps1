# Configuration
$WebhookUrl = "YOUR_SLACK_WEBHOOK_URL_HERE"

# 1. Interactive CLI Prompts
Clear-Host
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "       FACILITY BUILDING ROUND LOGGER - CLI         " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Manager Initials
$Initials = Read-Host "Enter Manager Initials (e.g., AL, JD, MK, SR)"
if ([string]::IsNullOrWhiteSpace($Initials)) {
    $Initials = "BM"
}

# Round Time
$RoundTime = Read-Host "Enter Round Time (e.g., 22:00, or press Enter for current time)"
if ([string]::IsNullOrWhiteSpace($RoundTime)) {
    $RoundTime = Get-Date -Format "HH:mm"
}

# Status & Log Details
$StatusOption = Read-Host "Select Status: [1] All Clear | [2] Incident / Maintenance Issue"

if ($StatusOption -eq "2") {
    $StatusTitle  = "Incident / Maintenance Issue"
    $BarColor     = "#E01E5A" # Slack Red Accent
    $Floor        = Read-Host "Enter Floor (e.g., 2nd Floor)"
    $Room         = Read-Host "Enter Room / Area (e.g., Room 204)"
    $Incident     = Read-Host "Enter Incident Details"
    
    $LocationText = "$Floor — $Room"
    $Observation  = $Incident
} else {
    $StatusTitle  = "All Clear"
    $BarColor     = "#2EB67D" # Slack Green Accent
    $LocationText = "Building Interior & Perimeter"
    $Notes        = Read-Host "Enter Notes (or press Enter for 'No issues observed')"
    if ([string]::IsNullOrWhiteSpace($Notes)) {
        $Notes = "Perimeter secure, access controls verified, no operational hazards observed."
    }
    $Observation  = $Notes
}

# 2. Executive Slack JSON Payload
$Payload = @{
    attachments = @(
        @{
            color = $BarColor
            blocks = @(
                @{
                    type = "header"
                    text = @{
                        type = "plain_text"
                        text = "Building Round Log — $RoundTime"
                    }
                },
                @{
                    type = "section"
                    fields = @(
                        @{
                            type = "mrkdwn"
                            text = "*Status:*`n$StatusTitle"
                        },
                        @{
                            type = "mrkdwn"
                            text = "*Location:*`n$LocationText"
                        }
                    )
                },
                @{
                    type = "section"
                    text = @{
                        type = "mrkdwn"
                        text = "*Observation:*`n$Observation"
                    }
                },
                @{
                    type = "context"
                    elements = @(
                        @{
                            type = "mrkdwn"
                            text = "Logged by *$Initials* \vert{}$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                        }
                    )
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

# 3. Transmit to Slack
try {
    Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $Payload -ContentType 'application/json'
    Write-Host "`nSUCCESS: Round log posted cleanly to Slack!" -ForegroundColor Green
} catch {
    Write-Host "`nERROR sending log to Slack: $_" -ForegroundColor Red
}