# dllBuilder

`dllBuilder.ps1` is a small Win32 (Windows Forms) helper that automates building `Stacks&Weight-80` into `StacksAndWeight80.dll`.

## What it automates

- Lets you choose the Valheim install folder
- Writes `Stacks&Weight-80/Environment.props` with your selected path
- Runs `dotnet build` for `StacksAndWeight80.csproj` in Debug or Release mode
- Shows build output in the UI

## Run

From PowerShell on Windows:

```powershell
cd <repo>\Moder\dllBuilder
powershell -ExecutionPolicy Bypass -File .\dllBuilder.ps1
```

> The script expects `dotnet` SDK to be installed and Valheim + BepInEx files to exist in the selected folder.
