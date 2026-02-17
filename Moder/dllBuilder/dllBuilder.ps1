Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $scriptPath)
$modProjectDir = Join-Path $repoRoot "Stacks&Weight-80"
$modProjectFile = Join-Path $modProjectDir "StacksAndWeight80.csproj"
$environmentFile = Join-Path $modProjectDir "Environment.props"

$form = New-Object System.Windows.Forms.Form
$form.Text = "dllBuilder"
$form.Size = New-Object System.Drawing.Size(640, 420)
$form.StartPosition = "CenterScreen"

$valheimLabel = New-Object System.Windows.Forms.Label
$valheimLabel.Location = New-Object System.Drawing.Point(12, 20)
$valheimLabel.Size = New-Object System.Drawing.Size(180, 20)
$valheimLabel.Text = "Valheim install path:"
$form.Controls.Add($valheimLabel)

$valheimPathText = New-Object System.Windows.Forms.TextBox
$valheimPathText.Location = New-Object System.Drawing.Point(12, 44)
$valheimPathText.Size = New-Object System.Drawing.Size(520, 20)
$valheimPathText.Text = "C:\Program Files (x86)\Steam\steamapps\common\Valheim"
$form.Controls.Add($valheimPathText)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(538, 42)
$browseButton.Size = New-Object System.Drawing.Size(80, 24)
$browseButton.Text = "Browse..."
$browseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select Valheim install folder"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $valheimPathText.Text = $dialog.SelectedPath
    }
})
$form.Controls.Add($browseButton)

$configLabel = New-Object System.Windows.Forms.Label
$configLabel.Location = New-Object System.Drawing.Point(12, 78)
$configLabel.Size = New-Object System.Drawing.Size(180, 20)
$configLabel.Text = "Build configuration:"
$form.Controls.Add($configLabel)

$configDropdown = New-Object System.Windows.Forms.ComboBox
$configDropdown.Location = New-Object System.Drawing.Point(12, 102)
$configDropdown.Size = New-Object System.Drawing.Size(160, 20)
$configDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
[void]$configDropdown.Items.Add("Debug")
[void]$configDropdown.Items.Add("Release")
$configDropdown.SelectedItem = "Release"
$form.Controls.Add($configDropdown)

$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(12, 170)
$outputBox.Size = New-Object System.Drawing.Size(606, 200)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$form.Controls.Add($outputBox)

$buildButton = New-Object System.Windows.Forms.Button
$buildButton.Location = New-Object System.Drawing.Point(12, 134)
$buildButton.Size = New-Object System.Drawing.Size(120, 28)
$buildButton.Text = "Build DLL"
$buildButton.Add_Click({
    $valheimPath = $valheimPathText.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($valheimPath) -or -not (Test-Path $valheimPath)) {
        [System.Windows.Forms.MessageBox]::Show("Please choose a valid Valheim install path.", "dllBuilder")
        return
    }

    $environmentContents = @"
<Project>
  <PropertyGroup>
    <VALHEIM_INSTALL>$($valheimPath.Replace('&', '&amp;'))</VALHEIM_INSTALL>
  </PropertyGroup>
</Project>
"@
    Set-Content -Path $environmentFile -Value $environmentContents -Encoding UTF8

    $configuration = $configDropdown.SelectedItem
    $outputBox.Text = "Running dotnet build -c $configuration`r`n"
    $outputBox.AppendText("Project: $modProjectFile`r`n`r`n")

    $buildOutput = & dotnet build $modProjectFile -c $configuration 2>&1 | Out-String
    $outputBox.AppendText($buildOutput)

    if ($LASTEXITCODE -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Build complete. Check output above for DLL path and copy status.", "dllBuilder")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Build failed. See output for details.", "dllBuilder")
    }
})
$form.Controls.Add($buildButton)

[void]$form.ShowDialog()
