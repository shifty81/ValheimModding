# Mods Directory

This directory houses all the Valheim mods created for this repository.

## Directory Structure

Each mod should be in its own subfolder with a clear, descriptive name:

```
mods/
├── ExampleMod/
│   ├── ExampleMod.cs
│   ├── ExampleMod.csproj
│   ├── manifest.json
│   ├── README.md
│   ├── icon.png
│   └── CHANGELOG.md
├── AnotherMod/
│   ├── AnotherMod.cs
│   ├── AnotherMod.csproj
│   └── ...
└── README.md (this file)
```

## Mod Structure Guidelines

Each mod folder should contain:

### Required Files

1. **`ModName.cs`** - Main plugin file(s)
2. **`ModName.csproj`** - C# project file
3. **`README.md`** - Mod documentation including:
   - Description
   - Features
   - Installation instructions
   - Configuration options
   - Known issues
   - Credits

### Recommended Files

4. **`manifest.json`** - Thunderstore manifest for easy distribution
5. **`icon.png`** - 256x256 mod icon for Thunderstore
6. **`CHANGELOG.md`** - Version history and changes
7. **`LICENSE`** - License file (if different from repository license)
8. **`Environment.props.template`** - Template for environment configuration

### Optional Files

- **`Config/`** - Configuration-related classes
- **`Patches/`** - Harmony patch classes
- **`Managers/`** - Manager classes
- **`Assets/`** - Asset bundles, sprites, etc.
- **`Localization/`** - Localization files

## Example manifest.json

```json
{
    "name": "YourModName",
    "version_number": "1.0.0",
    "website_url": "https://github.com/shifty81/ValheimModding",
    "description": "A brief description of what your mod does",
    "dependencies": [
        "denikson-BepInExPack_Valheim-5.4.2200",
        "ValheimModding-Jotunn-2.19.4"
    ]
}
```

## Environment Configuration

Each mod should include an `Environment.props.template` file:

```xml
<Project>
  <PropertyGroup>
    <!-- Set this to your Valheim install path -->
    <VALHEIM_INSTALL>C:\Program Files (x86)\Steam\steamapps\common\Valheim</VALHEIM_INSTALL>
  </PropertyGroup>
</Project>
```

Developers should copy this to `Environment.props` and update with their local path.
The actual `Environment.props` is gitignored to avoid committing local paths.

## Building Mods

From within a mod directory:

```bash
# Build the mod
dotnet build

# Build in Release mode
dotnet build -c Release

# Clean and rebuild
dotnet clean && dotnet build
```

## Testing Mods Locally

1. Build your mod
2. Copy the DLL from `bin/Debug/net462/` to your Valheim `BepInEx/plugins/` folder
3. Launch Valheim
4. Check `BepInEx/LogOutput.log` for errors

Or set up automatic copying in your `.csproj`:

```xml
<Target Name="PostBuild" AfterTargets="PostBuildEvent">
  <Exec Command="copy /Y &quot;$(TargetPath)&quot; &quot;$(VALHEIM_INSTALL)\BepInEx\plugins\$(TargetFileName)&quot;" />
</Target>
```

## Distribution

### Thunderstore

1. Create a `thunderstore_build/` folder in your mod directory
2. Copy `manifest.json`, `icon.png`, `README.md`, and the built DLL
3. Zip the contents (not the folder itself)
4. Upload to [Thunderstore](https://valheim.thunderstore.io/)

### Nexus Mods

1. Build your mod in Release mode
2. Package the DLL with README and installation instructions
3. Upload to [Nexus Mods](https://www.nexusmods.com/valheim)

## Mod Development Resources

- [Framework Documentation](../docs/FRAMEWORKS.md)
- [Development Setup Guide](../docs/DEVELOPMENT_SETUP.md)
- [Best Practices](../docs/BEST_PRACTICES.md)
- [Harmony Patching Guide](../docs/HARMONY_GUIDE.md)
- [Code Examples](../docs/EXAMPLES.md)

## Getting Help

- Check existing mod code in this directory for examples
- Review the documentation in the `docs/` folder
- Join the [Valheim Modding Discord](https://discord.gg/RBq2mzeu4z)
- Ask in the repository discussions or issues
