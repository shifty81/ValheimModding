# Stacks & Weight -80%

A Valheim mod that reduces item weight by 80% and increases resource stack sizes to 500.

## Features

- **Weight Reduction**: All items with weight > 0 have their weight reduced by 80% (multiplied by 0.2)
- **Stack Size Increase**: All stackable resources (items with max stack > 1) have their stack size set to 500

## Requirements

- [BepInEx](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/) (5.4.2200 or later)

## Installation

1. Install BepInEx for Valheim
2. Copy `StacksAndWeight80.dll` into `BepInEx/plugins/`
3. Launch Valheim

## Building from Source

1. Copy `Environment.props.template` to `Environment.props`
2. Update `VALHEIM_INSTALL` in `Environment.props` to point to your Valheim installation
3. Build with `dotnet build` or open in Visual Studio / Rider

### Optional: Automated DLL Builder (Windows)

If you want a guided Win32 interface for building, use:

- `..\Moder\dllBuilder\dllBuilder.ps1`

It lets you select your Valheim path, choose Debug/Release, and run `dotnet build` automatically.

## How It Works

The mod uses a Harmony postfix patch on `ObjectDB.Awake` to modify all item shared data when the game's object database initializes:

- Iterates over all registered items in `ObjectDB.m_items`
- For each item with `m_weight > 0`, multiplies the weight by 0.2 (80% reduction)
- For each item with `m_maxStackSize > 1` (i.e., stackable resources), sets the max stack size to 500

## Technical Details

| Setting | Value |
|---------|-------|
| Weight multiplier | 0.2 (80% reduction) |
| Resource stack size | 500 |
| Plugin GUID | `com.shifty81.stacksandweight80` |

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
