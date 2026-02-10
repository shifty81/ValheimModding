# Best Practices for Valheim Mod Development

This guide outlines best practices for creating robust, maintainable, and compatible Valheim mods.

## Table of Contents
- [General Principles](#general-principles)
- [Code Organization](#code-organization)
- [Harmony Patching Best Practices](#harmony-patching-best-practices)
- [Configuration Management](#configuration-management)
- [Networking and Multiplayer](#networking-and-multiplayer)
- [Performance Optimization](#performance-optimization)
- [Testing and Quality Assurance](#testing-and-quality-assurance)
- [Distribution and Documentation](#distribution-and-documentation)

---

## General Principles

### 1. Follow the Single Responsibility Principle

Each class and method should have one clear purpose.

**Bad:**
```csharp
public class GameManager
{
    public void DoEverything() 
    {
        // Handles items, combat, UI, networking...
    }
}
```

**Good:**
```csharp
public class ItemManager { /* Item-related logic */ }
public class CombatManager { /* Combat-related logic */ }
public class UIManager { /* UI-related logic */ }
```

### 2. Use Meaningful Names

Choose descriptive names for variables, methods, and classes.

**Bad:**
```csharp
float x = 1.5f;
void DoStuff() { }
```

**Good:**
```csharp
float damageMultiplier = 1.5f;
void ApplyDamageModification() { }
```

### 3. Minimize Dependencies

Only reference assemblies and libraries you actually use.

### 4. Version Your Mod Properly

Use semantic versioning: `MAJOR.MINOR.PATCH`
- **MAJOR**: Breaking changes
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes

---

## Code Organization

### Project Structure

```
YourMod/
├── Config/
│   └── ModConfig.cs           # Configuration classes
├── Managers/
│   ├── ItemManager.cs         # Custom item handling
│   └── RecipeManager.cs       # Recipe management
├── Patches/
│   ├── PlayerPatches.cs       # Player-related Harmony patches
│   └── InventoryPatches.cs    # Inventory-related patches
├── Utils/
│   └── Helper.cs              # Utility functions
├── YourMod.cs                 # Main plugin class
└── ModInfo.cs                 # Metadata constants
```

### Namespace Organization

```csharp
namespace YourModName
{
    // Main plugin
}

namespace YourModName.Configuration
{
    // Configuration classes
}

namespace YourModName.Patches
{
    // Harmony patches
}

namespace YourModName.Managers
{
    // Manager classes
}
```

### Separate Concerns

Keep your main plugin class clean:

```csharp
[BepInPlugin(PluginGUID, PluginName, PluginVersion)]
[BepInDependency(Jotunn.Main.ModGuid)]
public class YourMod : BaseUnityPlugin
{
    public const string PluginGUID = "com.author.modname";
    public const string PluginName = "ModName";
    public const string PluginVersion = "1.0.0";

    private void Awake()
    {
        LoadConfiguration();
        InitializeManagers();
        ApplyPatches();
        RegisterEventHandlers();
    }

    private void LoadConfiguration() { /* ... */ }
    private void InitializeManagers() { /* ... */ }
    private void ApplyPatches() { /* ... */ }
    private void RegisterEventHandlers() { /* ... */ }
}
```

---

## Harmony Patching Best Practices

### 1. Keep Patches Static

All Harmony patch methods **must** be static.

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.Update))]
public class PlayerPatches
{
    [HarmonyPostfix]
    private static void Update_Postfix(Player __instance)
    {
        // Patch logic
    }
}
```

### 2. Use Descriptive Patch Names

Name your patch methods to indicate what they do.

**Bad:**
```csharp
[HarmonyPostfix]
private static void Postfix1(Player __instance) { }
```

**Good:**
```csharp
[HarmonyPostfix]
private static void ApplyCustomStaminaRegeneration_Postfix(Player __instance) { }
```

### 3. Specify Method Signatures for Overloads

When patching overloaded methods, specify the exact signature:

```csharp
[HarmonyPatch(typeof(Inventory), nameof(Inventory.AddItem), 
    new Type[] { typeof(ItemDrop.ItemData), typeof(int) })]
public class InventoryPatches
{
    [HarmonyPrefix]
    private static bool AddItem_Prefix(ItemDrop.ItemData item, int amount)
    {
        // Patch logic
        return true;
    }
}
```

### 4. Return Appropriate Values

- **Prefix**: Return `false` to skip the original method, `true` to run it
- **Postfix**: Return `void` (cannot skip execution)

### 5. Use AccessTools for Reflection

```csharp
using HarmonyLib;

// Get a private field
var healthField = AccessTools.Field(typeof(Character), "m_health");
float health = (float)healthField.GetValue(characterInstance);

// Call a private method
var eatMethod = AccessTools.Method(typeof(Player), "Eat");
eatMethod.Invoke(playerInstance, new object[] { item, true });
```

### 6. Minimize Patch Scope

Only patch what's necessary. Don't patch frequently-called methods unless required.

**Avoid patching:**
- `Update()` methods (called every frame)
- `FixedUpdate()` methods
- Very low-level methods

If you must patch these, keep the logic extremely lightweight.

### 7. Handle Null References

Always check for null before accessing patched instances:

```csharp
[HarmonyPostfix]
private static void Postfix(Player __instance)
{
    if (__instance == null) return;
    if (__instance.GetInventory() == null) return;
    
    // Safe to proceed
}
```

### 8. Unpatch on Cleanup

```csharp
private Harmony _harmony;

private void Awake()
{
    _harmony = new Harmony(PluginGUID);
    _harmony.PatchAll();
}

private void OnDestroy()
{
    _harmony?.UnpatchSelf();
}
```

---

## Configuration Management

### 1. Use BepInEx Configuration

```csharp
public class ModConfig
{
    public static ConfigEntry<bool> ModEnabled;
    public static ConfigEntry<float> DamageMultiplier;
    public static ConfigEntry<int> MaxInventorySize;

    public static void LoadConfig(ConfigFile config)
    {
        ModEnabled = config.Bind("General", "Enabled", true,
            "Enable or disable the mod");

        DamageMultiplier = config.Bind("Combat", "DamageMultiplier", 1.0f,
            new ConfigDescription(
                "Multiplier for all damage dealt",
                new AcceptableValueRange<float>(0.1f, 10f)
            ));

        MaxInventorySize = config.Bind("Inventory", "MaxSize", 32,
            new ConfigDescription(
                "Maximum inventory slots",
                new AcceptableValueRange<int>(8, 64)
            ));
    }
}
```

### 2. Organize Configuration Sections

Group related settings into sections:
- **General**: Core mod settings
- **Combat**: Combat-related tweaks
- **Crafting**: Recipe and crafting changes
- **UI**: User interface settings

### 3. Provide Clear Descriptions

```csharp
Config.Bind("Section", "Key", defaultValue,
    new ConfigDescription(
        "Clear description of what this setting does and its effects",
        new AcceptableValueRange<float>(min, max)
    ));
```

### 4. React to Configuration Changes

```csharp
private void Awake()
{
    ModConfig.LoadConfig(Config);
    
    // Subscribe to changes
    ModConfig.DamageMultiplier.SettingChanged += OnDamageMultiplierChanged;
}

private void OnDamageMultiplierChanged(object sender, EventArgs e)
{
    // React to the configuration change
    UpdateDamageCalculations();
}
```

---

## Networking and Multiplayer

### 1. Use Jotunn's NetworkCompatibility

```csharp
[BepInPlugin(PluginGUID, PluginName, PluginVersion)]
[BepInDependency(Jotunn.Main.ModGuid)]
[NetworkCompatibility(CompatibilityLevel.EveryoneMustHaveMod, VersionStrictness.Minor)]
public class YourMod : BaseUnityPlugin
{
    // ...
}
```

**Compatibility Levels:**
- `EveryoneMustHaveMod`: All players must have the mod
- `ClientMustHaveMod`: Clients need it, servers optional
- `ServerMustHaveMod`: Server needs it, clients optional
- `ClientOptional`: Mod is purely cosmetic/client-side

### 2. Test Multiplayer Scenarios

- Test as host
- Test as client
- Test with different mod configurations
- Test with players who don't have the mod (if applicable)

### 3. Synchronize Important Data

Use Jotunn's synchronization features for server-authoritative data:

```csharp
// Server-side only
if (ZNet.instance.IsServer())
{
    // Perform server-side logic
}

// Send data to all clients
ZRoutedRpc.instance.InvokeRoutedRPC(ZRoutedRpc.Everybody, "RPC_MethodName", args);
```

---

## Performance Optimization

### 1. Cache References

Don't repeatedly fetch the same references:

**Bad:**
```csharp
void Update()
{
    if (Player.m_localPlayer != null)
    {
        Player.m_localPlayer.GetHealth();
    }
}
```

**Good:**
```csharp
private Player _localPlayer;

void Update()
{
    if (_localPlayer == null)
        _localPlayer = Player.m_localPlayer;
    
    if (_localPlayer != null)
    {
        _localPlayer.GetHealth();
    }
}
```

### 2. Use Object Pooling

For frequently instantiated objects:

```csharp
private Queue<GameObject> _objectPool = new Queue<GameObject>();

private GameObject GetPooledObject()
{
    if (_objectPool.Count > 0)
        return _objectPool.Dequeue();
    
    return Instantiate(prefab);
}

private void ReturnToPool(GameObject obj)
{
    obj.SetActive(false);
    _objectPool.Enqueue(obj);
}
```

### 3. Avoid LINQ in Hot Paths

LINQ creates garbage and can be slow in frequently-called code:

**Bad (in Update()):**
```csharp
var enemies = FindObjectsOfType<Character>().Where(c => c.IsEnemy()).ToList();
```

**Good:**
```csharp
var enemies = new List<Character>();
foreach (var character in Character.GetAllCharacters())
{
    if (character.IsEnemy())
        enemies.Add(character);
}
```

### 4. Limit FindObjectOfType Usage

Cache results instead of searching every frame:

```csharp
private Player _player;

private Player GetPlayer()
{
    if (_player == null)
        _player = Player.m_localPlayer;
    return _player;
}
```

---

## Testing and Quality Assurance

### 1. Test in Different Scenarios

- Fresh new world
- Existing worlds with progress
- Different biomes
- Single-player and multiplayer
- With and without other mods

### 2. Handle Edge Cases

```csharp
// Always validate inputs
if (item == null) return;
if (amount <= 0) return;
if (inventory == null || inventory.GetEmptySlots() == 0) return;

// Proceed with logic
```

### 3. Provide Useful Error Messages

```csharp
try
{
    // Your code
}
catch (Exception ex)
{
    Jotunn.Logger.LogError($"Failed to process item: {ex.Message}");
    Jotunn.Logger.LogError($"Stack trace: {ex.StackTrace}");
}
```

### 4. Version Compatibility

Test with different Valheim versions when possible, and clearly document which game version your mod supports.

---

## Distribution and Documentation

### 1. Create a Comprehensive README

Include:
- **Description**: What your mod does
- **Features**: List of features
- **Installation**: Step-by-step guide
- **Configuration**: Available settings
- **Compatibility**: Known compatible/incompatible mods
- **Known Issues**: Current bugs or limitations
- **Changelog**: Version history

### 2. Use a Manifest File

For Thunderstore, create `manifest.json`:

```json
{
    "name": "YourModName",
    "version_number": "1.0.0",
    "website_url": "https://github.com/yourusername/yourmod",
    "description": "Short description of your mod",
    "dependencies": [
        "denikson-BepInExPack_Valheim-5.4.2200",
        "ValheimModding-Jotunn-2.19.4"
    ]
}
```

### 3. Version Your Releases Properly

- Use Git tags for releases
- Create release notes for each version
- Maintain a changelog

### 4. License Your Code

Choose an appropriate license (MIT, GPL, etc.) and include it in your repository.

### 5. Provide Support Channels

- GitHub Issues for bug reports
- Discord for community support
- Clear contribution guidelines

---

## Additional Best Practices

### Error Recovery

```csharp
private void Awake()
{
    try
    {
        LoadConfiguration();
        InitializeComponents();
    }
    catch (Exception ex)
    {
        Logger.LogError($"Failed to initialize mod: {ex}");
        // Provide graceful degradation
    }
}
```

### Logging Levels

```csharp
Logger.LogDebug("Detailed information for debugging");
Logger.LogInfo("General information");
Logger.LogWarning("Something unexpected but not critical");
Logger.LogError("An error occurred");
Logger.LogFatal("Critical error, mod cannot function");
```

### Code Comments

Comment **why**, not **what**:

**Bad:**
```csharp
// Add 1 to count
count += 1;
```

**Good:**
```csharp
// Increment because the game counts from 1, not 0
count += 1;
```

---

## Resources

- [Valtools Best Practices](https://valtools.org/wiki.php?page=Best-Practices)
- [BepInEx Plugin Guide](https://docs.bepinex.dev/articles/dev_guide/plugin_tutorial/)
- [C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [Unity Best Practices](https://unity.com/how-to/programming-unity)

---

## Next Steps

- Study [Harmony Patching Guide](HARMONY_GUIDE.md) for advanced patching techniques
- Explore [Code Examples](EXAMPLES.md) for practical implementations
- Review [Community Resources](RESOURCES.md) for additional learning materials
