Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$nl = [Environment]::NewLine

$form = New-Object System.Windows.Forms.Form
$form.Text = "Valheim Mod DLL Builder"
$form.Size = New-Object System.Drawing.Size(660, 520)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false

$tooltip = New-Object System.Windows.Forms.ToolTip

# --- Project file (.csproj) ---
$projectLabel = New-Object System.Windows.Forms.Label
$projectLabel.Location = New-Object System.Drawing.Point(12, 14)
$projectLabel.Size = New-Object System.Drawing.Size(610, 20)
$projectLabel.Text = "Project file (.csproj):"
$projectLabel.Font = New-Object System.Drawing.Font($projectLabel.Font, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($projectLabel)

$projectHint = New-Object System.Windows.Forms.Label
$projectHint.Location = New-Object System.Drawing.Point(12, 34)
$projectHint.Size = New-Object System.Drawing.Size(610, 16)
$projectHint.Text = "Select the .csproj file for any Valheim mod you want to build."
$projectHint.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($projectHint)

$projectPathText = New-Object System.Windows.Forms.TextBox
$projectPathText.Location = New-Object System.Drawing.Point(12, 54)
$projectPathText.Size = New-Object System.Drawing.Size(520, 20)
$projectPathText.Text = ""
$tooltip.SetToolTip($projectPathText, "Full path to the .csproj file of the mod you want to build.")
$form.Controls.Add($projectPathText)

$projectBrowseButton = New-Object System.Windows.Forms.Button
$projectBrowseButton.Location = New-Object System.Drawing.Point(538, 52)
$projectBrowseButton.Size = New-Object System.Drawing.Size(100, 24)
$projectBrowseButton.Text = "Browse..."
$projectBrowseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "Select a .csproj project file"
    $dialog.Filter = "C# Project Files (*.csproj)|*.csproj|All Files (*.*)|*.*"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $projectPathText.Text = $dialog.FileName
    }
})
$form.Controls.Add($projectBrowseButton)

# --- Valheim install path ---
$valheimLabel = New-Object System.Windows.Forms.Label
$valheimLabel.Location = New-Object System.Drawing.Point(12, 88)
$valheimLabel.Size = New-Object System.Drawing.Size(610, 20)
$valheimLabel.Text = "Valheim install path:"
$valheimLabel.Font = New-Object System.Drawing.Font($valheimLabel.Font, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($valheimLabel)

$valheimHint = New-Object System.Windows.Forms.Label
$valheimHint.Location = New-Object System.Drawing.Point(12, 108)
$valheimHint.Size = New-Object System.Drawing.Size(610, 16)
$valheimHint.Text = "Folder where Valheim is installed (must contain BepInEx\core and valheim_Data\Managed)."
$valheimHint.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($valheimHint)

$valheimPathText = New-Object System.Windows.Forms.TextBox
$valheimPathText.Location = New-Object System.Drawing.Point(12, 128)
$valheimPathText.Size = New-Object System.Drawing.Size(520, 20)
$valheimPathText.Text = "C:\Program Files (x86)\Steam\steamapps\common\Valheim"
$tooltip.SetToolTip($valheimPathText, "The root folder of your Valheim installation. BepInEx and game DLLs are resolved from here.")
$form.Controls.Add($valheimPathText)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(538, 126)
$browseButton.Size = New-Object System.Drawing.Size(100, 24)
$browseButton.Text = "Browse..."
$browseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select Valheim install folder"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $valheimPathText.Text = $dialog.SelectedPath
    }
})
$form.Controls.Add($browseButton)

# --- Build configuration ---
$configLabel = New-Object System.Windows.Forms.Label
$configLabel.Location = New-Object System.Drawing.Point(12, 162)
$configLabel.Size = New-Object System.Drawing.Size(180, 20)
$configLabel.Text = "Build configuration:"
$configLabel.Font = New-Object System.Drawing.Font($configLabel.Font, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($configLabel)

$configHint = New-Object System.Windows.Forms.Label
$configHint.Location = New-Object System.Drawing.Point(12, 182)
$configHint.Size = New-Object System.Drawing.Size(610, 16)
$configHint.Text = "Release = optimised DLL for distribution. Debug = includes extra info for troubleshooting."
$configHint.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($configHint)

$configDropdown = New-Object System.Windows.Forms.ComboBox
$configDropdown.Location = New-Object System.Drawing.Point(12, 202)
$configDropdown.Size = New-Object System.Drawing.Size(160, 20)
$configDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
[void]$configDropdown.Items.Add("Debug")
[void]$configDropdown.Items.Add("Release")
$configDropdown.SelectedItem = "Release"
$tooltip.SetToolTip($configDropdown, "Choose Debug for development or Release for a final build.")
$form.Controls.Add($configDropdown)

# --- Build button ---
$buildButton = New-Object System.Windows.Forms.Button
$buildButton.Location = New-Object System.Drawing.Point(12, 234)
$buildButton.Size = New-Object System.Drawing.Size(120, 28)
$buildButton.Text = "Build DLL"
$tooltip.SetToolTip($buildButton, "Writes Environment.props next to the .csproj and runs dotnet build.")
$buildButton.Add_Click({
    $projectFile = $projectPathText.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($projectFile) -or -not (Test-Path $projectFile)) {
        [System.Windows.Forms.MessageBox]::Show("Please choose a valid .csproj project file.", "dllBuilder")
        return
    }

    $valheimPath = $valheimPathText.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($valheimPath) -or -not (Test-Path $valheimPath)) {
        [System.Windows.Forms.MessageBox]::Show("Please choose a valid Valheim install path.", "dllBuilder")
        return
    }

    $projectDir = Split-Path -Parent $projectFile
    $environmentFile = Join-Path $projectDir "Environment.props"

    $escapedPath = [System.Security.SecurityElement]::Escape($valheimPath)
    $environmentContents = @"
<Project>
  <PropertyGroup>
    <VALHEIM_INSTALL>$escapedPath</VALHEIM_INSTALL>
  </PropertyGroup>
</Project>
"@
    Set-Content -Path $environmentFile -Value $environmentContents -Encoding UTF8

    $configuration = $configDropdown.SelectedItem
    $outputBox.Text = "Running dotnet build -c $configuration$nl"
    $outputBox.AppendText("Project: $projectFile$nl$nl")

    $buildSucceeded = $false
    try {
        $buildOutput = & dotnet build $projectFile -c $configuration 2>&1
        $buildSucceeded = ($LASTEXITCODE -eq 0)
        $outputBox.AppendText(($buildOutput | Out-String))
    } catch {
        $outputBox.AppendText("Unable to run dotnet build. Ensure .NET SDK is installed and 'dotnet' is in PATH.$nl")
        $outputBox.AppendText($_.Exception.Message + $nl)
    }

    if ($buildSucceeded) {
        [System.Windows.Forms.MessageBox]::Show("Build complete. Check output above for DLL path and copy status.", "dllBuilder")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Build failed. See output for details.", "dllBuilder")
    }
})
$form.Controls.Add($buildButton)

# --- Output ---
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Location = New-Object System.Drawing.Point(12, 270)
$outputLabel.Size = New-Object System.Drawing.Size(610, 16)
$outputLabel.Text = "Build output:"
$outputLabel.Font = New-Object System.Drawing.Font($outputLabel.Font, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($outputLabel)

$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(12, 290)
$outputBox.Size = New-Object System.Drawing.Size(624, 180)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$form.Controls.Add($outputBox)

[void]$form.ShowDialog()
