# Valheim Modding Frameworks

This guide covers the essential frameworks used in Valheim modding.

## Table of Contents
- [BepInEx](#bepinex)
- [Jotunn (Jötunn)](#jotunn-jötunn)
- [Harmony](#harmony)
- [Framework Comparison](#framework-comparison)

---

## BepInEx

**BepInEx** (BepInEx Plugin Framework) is the foundational modding framework for Unity games, including Valheim.

### What is BepInEx?

- A **mod loader** and **plugin framework** for Unity games
- Allows mods to be loaded without modifying original game files
- Provides a standardized API for mod development
- Handles mod initialization, configuration, and logging

### Key Features

- **Plugin System**: Load C# plugins at runtime
- **Configuration Management**: Built-in configuration system
- **Logging**: Comprehensive logging for debugging
- **Harmony Integration**: Built-in support for runtime patching
- **Event System**: Hook into game lifecycle events

### Installation

#### For Players (Manual):
1. Download BepInExPack_Valheim from [Thunderstore](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/)
2. Extract to your Valheim root directory (where `valheim.exe` is located)
3. Run the game once to generate configuration files
4. Place mods in `BepInEx/plugins/` folder

#### For Players (Mod Manager):
1. Install [r2modman](https://thunderstore.io/c/valheim/p/ebkr/r2modman/) or Thunderstore Mod Manager
2. The manager will automatically install BepInEx
3. Install mods through the manager interface

#### For Servers:
1. Download BepInExPack_Valheim
2. Extract to your Valheim server directory (where `valheim_server.exe` is located)
3. Start the server to generate configuration files
4. Place mods in `BepInEx/plugins/` folder
5. Ensure clients have matching mods for multiplayer compatibility

### Directory Structure

```
Valheim/
├── BepInEx/
│   ├── config/          # Mod configuration files
│   ├── plugins/         # Installed mods (.dll files)
│   ├── core/            # BepInEx core files
│   └── LogOutput.log    # Debug log file
├── doorstop_config.ini  # BepInEx loader configuration
└── valheim.exe          # Game executable
```

### Resources

- [Official BepInEx Documentation](https://docs.bepinex.dev/)
- [BepInEx GitHub](https://github.com/BepInEx/BepInEx)
- [Thunderstore Page](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/)

---

## Jotunn (Jötunn)

**Jotunn** (Jötunn, The Valheim Library) is a high-level modding library built on top of BepInEx, specifically designed for Valheim.

### What is Jotunn?

- A comprehensive **utility library** for Valheim mod development
- Provides **abstractions** for common modding tasks
- Handles **network synchronization** for multiplayer compatibility
- Offers **helper functions** for items, recipes, creatures, and more

### Why Use Jotunn?

1. **Simplified API**: Easy-to-use interfaces for complex operations
2. **Network Safety**: Built-in multiplayer synchronization
3. **Version Compatibility**: Handles game updates more gracefully
4. **Community Standard**: Most modern mods use Jotunn
5. **Active Development**: Regularly updated with new features

### Key Features

#### Custom Assets
- Add custom items, weapons, and armor
- Create custom creatures and NPCs
- Define custom recipes and crafting stations
- Add custom pieces (buildings)

#### Managers
- **ItemManager**: Handle custom items
- **PieceManager**: Manage building pieces
- **CreatureManager**: Spawn and configure creatures
- **RecipeManager**: Define crafting recipes
- **KeyHintManager**: Add UI key hints
- **MinimapManager**: Customize minimap

#### Utilities
- **LocalizationManager**: Multi-language support
- **PrefabManager**: Asset bundle management
- **CommandManager**: Add console commands
- **InputManager**: Handle custom keybindings

### Installation

#### As a Developer Dependency:
```xml
<!-- In your .csproj file -->
<ItemGroup>
  <Reference Include="Jotunn">
    <HintPath>path/to/Jotunn.dll</HintPath>
  </Reference>
</ItemGroup>
```

#### As a Mod Dependency:
Users installing your mod will need Jotunn installed. List it as a dependency in your mod manifest.

### Basic Usage Example

```csharp
using BepInEx;
using Jotunn;
using Jotunn.Entities;
using Jotunn.Managers;

[BepInPlugin(PluginGUID, PluginName, PluginVersion)]
[BepInDependency(Jotunn.Main.ModGuid)]
public class MyMod : BaseUnityPlugin
{
    private const string PluginGUID = "com.author.mymod";
    private const string PluginName = "My Awesome Mod";
    private const string PluginVersion = "1.0.0";

    private void Awake()
    {
        // Add a custom item
        ItemManager.Instance.AddItem(new CustomItem(itemPrefab, fixReference: true));
        
        // Add a custom recipe
        RecipeManager.Instance.AddRecipe(new CustomRecipe(recipeConfig));
    }
}
```

### Resources

- [Official Jotunn Documentation](https://valheim-modding.github.io/Jotunn/)
- [Jotunn GitHub Repository](https://github.com/Valheim-Modding/Jotunn)
- [JotunnModStub Template](https://github.com/Valheim-Modding/JotunnModStub)
- [JotunnModExample](https://github.com/Valheim-Modding/JotunnModExample)
- [Nexus Mods Page](https://www.nexusmods.com/valheim/mods/1138)

---

## Harmony

**Harmony** is a library for runtime code patching in .NET applications.

### What is Harmony?

- Allows **modifying game code at runtime** without changing original files
- Supports **Prefix**, **Postfix**, and **Transpiler** patches
- Enables multiple mods to patch the same method safely
- Essential for modding compiled games

### Patch Types

#### Prefix Patches
Run **before** the original method. Can skip the original method entirely.

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.Update))]
[HarmonyPrefix]
static bool Prefix_PlayerUpdate(Player __instance)
{
    // Your code here
    // Return false to skip original method
    return true;
}
```

#### Postfix Patches
Run **after** the original method. Can modify return values.

```csharp
[HarmonyPatch(typeof(Inventory), nameof(Inventory.GetTotalWeight))]
[HarmonyPostfix]
static void Postfix_GetTotalWeight(ref float __result)
{
    // Modify the weight calculation
    __result *= 0.5f; // Half weight
}
```

#### Transpiler Patches
Modify the **IL code** of the method. Most powerful but complex.

### Basic Setup

```csharp
using HarmonyLib;

[BepInPlugin(PluginGUID, PluginName, PluginVersion)]
public class MyMod : BaseUnityPlugin
{
    private Harmony harmony;

    private void Awake()
    {
        harmony = new Harmony(PluginGUID);
        harmony.PatchAll(); // Patches all [HarmonyPatch] methods
    }

    private void OnDestroy()
    {
        harmony?.UnpatchSelf(); // Clean up patches
    }
}
```

### Resources

- [Harmony Documentation](https://harmony.pardeike.net/)
- [BepInEx Harmony Guide](https://docs.bepinex.dev/master/articles/dev_guide/runtime_patching.html)

---

## Framework Comparison

| Feature | BepInEx | Jotunn | Harmony |
|---------|---------|--------|---------|
| **Purpose** | Mod loader | High-level API | Code patching |
| **Required** | ✅ Yes | ❌ Optional | ⚠️ Via BepInEx |
| **Learning Curve** | Medium | Low | High |
| **Use Case** | Foundation | Custom content | Game logic changes |
| **Network Sync** | Manual | Automatic | Manual |
| **Asset Management** | Manual | Built-in | N/A |

### When to Use What?

- **BepInEx**: Always required as the foundation
- **Jotunn**: Use for adding custom items, creatures, recipes, and buildings
- **Harmony**: Use for modifying existing game behavior and mechanics

### Typical Mod Stack

```
Your Mod
    ↓
Jotunn (Optional, for custom content)
    ↓
Harmony (Via BepInEx, for patching)
    ↓
BepInEx (Required)
    ↓
Valheim
```

---

## Next Steps

- Learn about [Development Setup](DEVELOPMENT_SETUP.md)
- Review [Best Practices](BEST_PRACTICES.md)
- Study [Harmony Patching Guide](HARMONY_GUIDE.md)
- Explore [Code Examples](EXAMPLES.md)
