# dllBuilder

`dllBuilder.ps1` is a universal Windows Forms helper that automates building any Valheim BepInEx mod into a `.dll`.

## What it automates

- Lets you pick **any** `.csproj` mod project file
- Lets you choose the Valheim install folder
- Writes `Environment.props` (next to the selected `.csproj`) with your selected path
- Runs `dotnet build` in Debug or Release mode
- Shows build output in the UI

## Fields in the window

| Field | Purpose |
|-------|---------|
| **Project file (.csproj)** | Full path to the `.csproj` you want to build. Use *Browse…* to pick any mod project. |
| **Valheim install path** | Root folder of your Valheim installation (must contain `BepInEx\core` and `valheim_Data\Managed`). |
| **Build configuration** | *Release* produces an optimised DLL for distribution. *Debug* includes extra info for troubleshooting. |

## Run

From PowerShell on Windows:

```powershell
cd <repo>\Moder\dllBuilder
powershell -ExecutionPolicy Bypass -File .\dllBuilder.ps1
```

Or double-click a shortcut that runs the command above.

> The script expects the `dotnet` SDK to be installed and Valheim + BepInEx files to exist in the selected folder.
