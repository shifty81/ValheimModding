# Development Setup Guide

This guide will help you set up a complete development environment for creating Valheim mods.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Setting Up Your IDE](#setting-up-your-ide)
- [Project Setup](#project-setup)
- [Building Your First Mod](#building-your-first-mod)
- [Debugging](#debugging)
- [Common Issues](#common-issues)

---

## Prerequisites

### Required Software

1. **Visual Studio 2022** (Community Edition is free)
   - Download: https://visualstudio.microsoft.com/
   - Workloads: .NET desktop development

   **Alternative IDEs:**
   - Visual Studio Code with C# extension
   - JetBrains Rider

2. **.NET SDK**
   - Valheim uses .NET Framework 4.6.2
   - Download: https://dotnet.microsoft.com/download

3. **Valheim Game**
   - Must own the game on Steam
   - Note the installation directory (usually `C:\Program Files (x86)\Steam\steamapps\common\Valheim`)

4. **Git** (for version control)
   - Download: https://git-scm.com/

### Recommended Tools

1. **dnSpy** - .NET debugger and assembly editor
   - Download: https://github.com/dnSpy/dnSpy/releases
   - Useful for reverse-engineering game code

2. **ILSpy** - .NET decompiler
   - Download: https://github.com/icsharpcode/ILSpy
   - Alternative to dnSpy for viewing game code

3. **Unity Asset Bundle Extractor (UABE)**
   - For extracting and viewing game assets
   - Download: https://github.com/SeriousCache/UABE

---

## Setting Up Your IDE

### Visual Studio 2022 Configuration

1. **Install Required Workloads:**
   - .NET desktop development
   - Game development with Unity (optional, for Unity API documentation)

2. **Install Extensions:**
   - GitHub Extension for Visual Studio
   - Visual Studio Tools for Unity (optional)

3. **Configure Build Output:**
   - Set output path to your Valheim `BepInEx/plugins` folder for automatic testing
   - Or use a post-build event to copy the DLL

### Visual Studio Code Configuration

1. **Install Extensions:**
   ```
   - C# (ms-dotnettools.csharp)
   - C# Dev Kit
   - Unity Tools (optional)
   ```

2. **Configure tasks.json:**
   ```json
   {
       "version": "2.0.0",
       "tasks": [
           {
               "label": "build",
               "command": "dotnet",
               "type": "process",
               "args": [
                   "build",
                   "${workspaceFolder}/YourMod.csproj",
                   "/property:GenerateFullPaths=true",
                   "/consoleloggerparameters:NoSummary"
               ],
               "problemMatcher": "$msCompile"
           }
       ]
   }
   ```

---

## Project Setup

### Option 1: Using JotunnModStub (Recommended)

This is the fastest and most reliable way to start a new mod.

1. **Create from Template:**
   ```bash
   # Clone the template
   git clone https://github.com/Valheim-Modding/JotunnModStub.git MyValheimMod
   cd MyValheimMod
   
   # Remove the template's git history
   rm -rf .git
   git init
   ```

2. **Configure Your Mod:**
   - Edit `ModInfo.cs` with your mod details:
     ```csharp
     public const string ModGUID = "com.yourname.yourmod";
     public const string ModName = "YourMod";
     public const string ModVersion = "1.0.0";
     ```

3. **Update Environment Variables:**
   - Edit `Environment.props` to point to your Valheim installation:
     ```xml
     <VALHEIM_INSTALL>C:\Program Files (x86)\Steam\steamapps\common\Valheim</VALHEIM_INSTALL>
     ```

4. **Build the Project:**
   ```bash
   dotnet build
   ```

### Option 2: Manual Setup

If you prefer to set up a project from scratch:

1. **Create a New Class Library Project:**
   ```bash
   dotnet new classlib -f net462 -n YourModName
   cd YourModName
   ```

2. **Edit the .csproj File:**
   ```xml
   <Project Sdk="Microsoft.NET.Sdk">
     <PropertyGroup>
       <TargetFramework>net462</TargetFramework>
       <AssemblyName>YourModName</AssemblyName>
       <LangVersion>latest</LangVersion>
       <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
       <DebugType>portable</DebugType>
     </PropertyGroup>

     <ItemGroup>
       <!-- BepInEx -->
       <Reference Include="BepInEx">
         <HintPath>$(VALHEIM_INSTALL)\BepInEx\core\BepInEx.dll</HintPath>
       </Reference>
       
       <!-- Jotunn -->
       <Reference Include="Jotunn">
         <HintPath>$(VALHEIM_INSTALL)\BepInEx\plugins\Jotunn.dll</HintPath>
       </Reference>
       
       <!-- Valheim Game Assemblies -->
       <Reference Include="assembly_valheim">
         <HintPath>$(VALHEIM_INSTALL)\valheim_Data\Managed\assembly_valheim.dll</HintPath>
       </Reference>
       
       <Reference Include="assembly_valheim_publicized">
         <HintPath>$(VALHEIM_INSTALL)\valheim_Data\Managed\publicized_assemblies\assembly_valheim_publicized.dll</HintPath>
       </Reference>
       
       <!-- Unity -->
       <Reference Include="UnityEngine">
         <HintPath>$(VALHEIM_INSTALL)\unstripped_corlib\UnityEngine.dll</HintPath>
       </Reference>
       
       <Reference Include="UnityEngine.CoreModule">
         <HintPath>$(VALHEIM_INSTALL)\unstripped_corlib\UnityEngine.CoreModule.dll</HintPath>
       </Reference>
     </ItemGroup>
   </Project>
   ```

3. **Set Environment Variable:**
   - Windows: Create `Environment.props` in your project root
   - Or set system environment variable `VALHEIM_INSTALL`

4. **Publicize Game Assemblies:**
   You need to publicize Valheim's assemblies to access internal classes:
   
   ```bash
   # Using AssemblyPublicizer (NuGet)
   dotnet add package BepInEx.AssemblyPublicizer.MSBuild
   ```

---

## Building Your First Mod

### Basic Mod Structure

Create `YourMod.cs`:

```csharp
using BepInEx;
using BepInEx.Configuration;
using HarmonyLib;
using Jotunn;
using Jotunn.Entities;
using Jotunn.Managers;
using Jotunn.Utils;
using UnityEngine;

namespace YourModName
{
    [BepInPlugin(PluginGUID, PluginName, PluginVersion)]
    [BepInDependency(Jotunn.Main.ModGuid)]
    [NetworkCompatibility(CompatibilityLevel.EveryoneMustHaveMod, VersionStrictness.Minor)]
    public class YourMod : BaseUnityPlugin
    {
        public const string PluginGUID = "com.yourname.yourmod";
        public const string PluginName = "YourMod";
        public const string PluginVersion = "1.0.0";

        private Harmony _harmony;

        // Configuration
        private ConfigEntry<bool> _modEnabled;
        private ConfigEntry<float> _modValue;

        private void Awake()
        {
            // Load configuration
            LoadConfig();

            // Apply Harmony patches
            _harmony = new Harmony(PluginGUID);
            _harmony.PatchAll();

            // Register for Jotunn events
            Jotunn.Logger.LogInfo($"{PluginName} has awoken!");
        }

        private void LoadConfig()
        {
            _modEnabled = Config.Bind("General", "Enabled", true,
                new ConfigDescription("Enable or disable the mod"));
            
            _modValue = Config.Bind("General", "ModValue", 1.0f,
                new ConfigDescription("A configurable value",
                    new AcceptableValueRange<float>(0f, 10f)));
        }

        private void OnDestroy()
        {
            _harmony?.UnpatchSelf();
        }
    }
}
```

### Build and Test

1. **Build the Project:**
   ```bash
   dotnet build
   ```

2. **Copy DLL to Valheim:**
   - Manual: Copy `bin/Debug/net462/YourModName.dll` to `BepInEx/plugins/`
   - Or set up automatic copying in post-build events:
     ```xml
     <Target Name="PostBuild" AfterTargets="PostBuildEvent">
       <Exec Command="copy /Y &quot;$(TargetPath)&quot; &quot;$(VALHEIM_INSTALL)\BepInEx\plugins\$(TargetFileName)&quot;" />
     </Target>
     ```

3. **Test in Valheim:**
   - Launch Valheim
   - Check `BepInEx/LogOutput.log` for your mod's initialization message
   - Press F5 to open the console and verify mod is loaded

---

## Debugging

### Method 1: Unity Debugging with dnSpy

1. **Launch Valheim with Debugging:**
   - Set BepInEx to enable debugging in `BepInEx/config/BepInEx.cfg`:
     ```ini
     [Logging.Disk]
     Enabled = true
     ```

2. **Attach dnSpy:**
   - Open dnSpy
   - Debug → Attach to Process → Select Valheim.exe
   - Open your mod's DLL and set breakpoints

### Method 2: Log-Based Debugging

Use extensive logging in your code:

```csharp
using Jotunn;

Logger.LogInfo("Normal information");
Logger.LogWarning("Warning message");
Logger.LogError("Error occurred");
Logger.LogDebug("Debug information (only shown if enabled)");
```

Enable debug logging in `BepInEx/config/BepInEx.cfg`:
```ini
[Logging.Console]
LogLevels = Fatal, Error, Warning, Message, Info, Debug
```

### Method 3: Visual Studio Debugging

1. **Configure Debug Settings:**
   - Right-click project → Properties → Debug
   - Start external program: `C:\...\Valheim\valheim.exe`
   - Enable native code debugging

2. **Attach Debugger:**
   - Debug → Attach to Process → Select valheim.exe

---

## Common Issues

### Issue: "Could not load assembly_valheim"

**Solution:**
- Verify your `VALHEIM_INSTALL` environment variable points to the correct directory
- Ensure the DLL path in your `.csproj` is correct
- Check that Valheim is installed and up-to-date

### Issue: "Type or namespace 'Jotunn' could not be found"

**Solution:**
- Install Jotunn in your Valheim BepInEx plugins folder first
- Verify the reference path in your `.csproj` file
- Rebuild the project

### Issue: Mod doesn't load in game

**Solution:**
1. Check `BepInEx/LogOutput.log` for errors
2. Verify your mod's DLL is in `BepInEx/plugins/`
3. Ensure BepInEx is properly installed
4. Check that your `[BepInPlugin]` attribute is correct

### Issue: "FileNotFoundException: Could not load file or assembly 'Jotunn'"

**Solution:**
- Install Jotunn as a dependency for your mod
- Add `[BepInDependency(Jotunn.Main.ModGuid)]` to your plugin class
- Ensure Jotunn.dll is in the BepInEx/plugins folder

### Issue: Changes not reflected in game

**Solution:**
- Completely close Valheim (check Task Manager)
- Delete the old DLL from plugins folder
- Rebuild and copy the new DLL
- Clear BepInEx cache if needed (delete `BepInEx/cache/`)

---

## Next Steps

- Review [Best Practices](BEST_PRACTICES.md) for coding guidelines
- Learn [Harmony Patching](HARMONY_GUIDE.md) for modifying game behavior
- Study [Code Examples](EXAMPLES.md) for common patterns
- Join the [Valheim Modding Discord](https://discord.gg/RBq2mzeu4z) for community support

---

## Additional Resources

- [Jotunn Documentation](https://valheim-modding.github.io/Jotunn/)
- [BepInEx Plugin Guide](https://docs.bepinex.dev/articles/dev_guide/plugin_tutorial/index.html)
- [Unity Scripting Reference](https://docs.unity3d.com/ScriptReference/)
- [Harmony Documentation](https://harmony.pardeike.net/)
