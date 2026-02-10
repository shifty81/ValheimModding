# Code Examples

Practical code examples for common Valheim modding tasks.

## Table of Contents
- [Basic Mod Setup](#basic-mod-setup)
- [Adding Custom Items](#adding-custom-items)
- [Adding Custom Recipes](#adding-custom-recipes)
- [Player Modifications](#player-modifications)
- [Inventory Management](#inventory-management)
- [Combat Modifications](#combat-modifications)
- [Custom Console Commands](#custom-console-commands)
- [Configuration Examples](#configuration-examples)

---

## Basic Mod Setup

### Minimal Mod Template

```csharp
using BepInEx;
using BepInEx.Configuration;
using HarmonyLib;

namespace YourModName
{
    [BepInPlugin(PluginGUID, PluginName, PluginVersion)]
    public class YourMod : BaseUnityPlugin
    {
        public const string PluginGUID = "com.yourname.yourmod";
        public const string PluginName = "Your Mod Name";
        public const string PluginVersion = "1.0.0";

        private Harmony _harmony;

        private void Awake()
        {
            Logger.LogInfo($"{PluginName} v{PluginVersion} is loading...");
            
            // Load configuration
            LoadConfig();
            
            // Apply Harmony patches
            _harmony = new Harmony(PluginGUID);
            _harmony.PatchAll();
            
            Logger.LogInfo($"{PluginName} loaded successfully!");
        }

        private void LoadConfig()
        {
            // Configuration setup here
        }

        private void OnDestroy()
        {
            _harmony?.UnpatchSelf();
        }
    }
}
```

### Mod with Jotunn

```csharp
using BepInEx;
using Jotunn;
using Jotunn.Entities;
using Jotunn.Managers;
using Jotunn.Utils;
using HarmonyLib;

namespace YourModName
{
    [BepInPlugin(PluginGUID, PluginName, PluginVersion)]
    [BepInDependency(Jotunn.Main.ModGuid)]
    [NetworkCompatibility(CompatibilityLevel.EveryoneMustHaveMod, VersionStrictness.Minor)]
    internal class YourMod : BaseUnityPlugin
    {
        public const string PluginGUID = "com.yourname.yourmod";
        public const string PluginName = "Your Mod Name";
        public const string PluginVersion = "1.0.0";

        private Harmony _harmony;

        private void Awake()
        {
            // Configuration
            LoadConfig();
            
            // Harmony patches
            _harmony = new Harmony(PluginGUID);
            _harmony.PatchAll();
            
            // Jotunn hooks
            PrefabManager.OnVanillaPrefabsAvailable += AddCustomContent;
        }

        private void LoadConfig()
        {
            // Config here
        }

        private void AddCustomContent()
        {
            // Add custom items, recipes, etc.
            PrefabManager.OnVanillaPrefabsAvailable -= AddCustomContent;
        }

        private void OnDestroy()
        {
            _harmony?.UnpatchSelf();
        }
    }
}
```

---

## Adding Custom Items

### Simple Custom Item

```csharp
using Jotunn.Entities;
using Jotunn.Managers;
using UnityEngine;

private void AddCustomItems()
{
    // Clone an existing item as a base
    var sword = PrefabManager.Instance.GetPrefab("SwordIron");
    var customSword = PrefabManager.Instance.CreateClonedPrefab("CustomSword", sword);
    
    // Modify the item
    var itemDrop = customSword.GetComponent<ItemDrop>();
    itemDrop.m_itemData.m_shared.m_name = "Custom Legendary Sword";
    itemDrop.m_itemData.m_shared.m_description = "A powerful custom weapon";
    itemDrop.m_itemData.m_shared.m_damages.m_slash = 75f;
    itemDrop.m_itemData.m_shared.m_damages.m_pierce = 25f;
    
    // Add to the game
    ItemManager.Instance.AddItem(new CustomItem(customSword, fixReference: true));
    
    Jotunn.Logger.LogInfo("Custom sword added!");
}
```

### Custom Item with Config

```csharp
private ConfigEntry<float> _customSwordDamage;

private void LoadConfig()
{
    _customSwordDamage = Config.Bind("Items", "CustomSwordDamage", 75f,
        new ConfigDescription("Damage value for the custom sword",
            new AcceptableValueRange<float>(1f, 200f)));
}

private void AddCustomItems()
{
    var sword = PrefabManager.Instance.GetPrefab("SwordIron");
    var customSword = PrefabManager.Instance.CreateClonedPrefab("CustomSword", sword);
    
    var itemDrop = customSword.GetComponent<ItemDrop>();
    itemDrop.m_itemData.m_shared.m_name = "Custom Sword";
    itemDrop.m_itemData.m_shared.m_damages.m_slash = _customSwordDamage.Value;
    
    ItemManager.Instance.AddItem(new CustomItem(customSword, fixReference: true));
}
```

---

## Adding Custom Recipes

### Basic Recipe

```csharp
using Jotunn.Entities;
using Jotunn.Managers;

private void AddCustomRecipes()
{
    // Create a recipe for crafting your custom item
    var recipe = new CustomRecipe(new RecipeConfig
    {
        Item = "CustomSword",
        CraftingStation = "forge",
        MinStationLevel = 2,
        Amount = 1,
        Requirements = new[]
        {
            new RequirementConfig { Item = "Iron", Amount = 20 },
            new RequirementConfig { Item = "Wood", Amount = 10 },
            new RequirementConfig { Item = "LeatherScraps", Amount = 5 }
        }
    });
    
    ItemManager.Instance.AddRecipe(recipe);
    Jotunn.Logger.LogInfo("Custom recipe added!");
}
```

### Configurable Recipe

```csharp
private ConfigEntry<int> _ironRequired;
private ConfigEntry<int> _woodRequired;

private void LoadConfig()
{
    _ironRequired = Config.Bind("Recipes", "IronRequired", 20,
        "Amount of iron required for custom sword");
    _woodRequired = Config.Bind("Recipes", "WoodRequired", 10,
        "Amount of wood required for custom sword");
}

private void AddCustomRecipes()
{
    var recipe = new CustomRecipe(new RecipeConfig
    {
        Item = "CustomSword",
        CraftingStation = "forge",
        Amount = 1,
        Requirements = new[]
        {
            new RequirementConfig { Item = "Iron", Amount = _ironRequired.Value },
            new RequirementConfig { Item = "Wood", Amount = _woodRequired.Value }
        }
    });
    
    ItemManager.Instance.AddRecipe(recipe);
}
```

---

## Player Modifications

### Increase Player Stats

```csharp
using HarmonyLib;

[HarmonyPatch(typeof(Player), nameof(Player.GetMaxStamina))]
public class PlayerStaminaPatch
{
    [HarmonyPostfix]
    private static void Postfix(ref float __result)
    {
        __result *= 2.0f; // Double maximum stamina
    }
}

[HarmonyPatch(typeof(Player), nameof(Player.GetBaseFoodHP))]
public class PlayerHealthPatch
{
    [HarmonyPostfix]
    private static void Postfix(ref float __result)
    {
        __result += 50f; // Add 50 base health
    }
}
```

### Modify Movement Speed

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.GetJogSpeedFactor))]
public class PlayerSpeedPatch
{
    private static ConfigEntry<float> _speedMultiplier;
    
    public static void Initialize(ConfigFile config)
    {
        _speedMultiplier = config.Bind("Player", "SpeedMultiplier", 1.5f,
            new ConfigDescription("Movement speed multiplier",
                new AcceptableValueRange<float>(0.5f, 5.0f)));
    }
    
    [HarmonyPostfix]
    private static void Postfix(ref float __result)
    {
        __result *= _speedMultiplier.Value;
    }
}
```

### Infinite Stamina

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.UseStamina))]
public class InfiniteStaminaPatch
{
    private static ConfigEntry<bool> _infiniteStamina;
    
    public static void Initialize(ConfigFile config)
    {
        _infiniteStamina = config.Bind("Player", "InfiniteStamina", false,
            "Enable infinite stamina");
    }
    
    [HarmonyPrefix]
    private static bool Prefix()
    {
        return !_infiniteStamina.Value; // Return false to skip stamina usage
    }
}
```

---

## Inventory Management

### Increase Inventory Size

```csharp
[HarmonyPatch(typeof(Inventory), MethodType.Constructor,
    new Type[] { typeof(string), typeof(Sprite), typeof(int), typeof(int) })]
public class InventorySizePatch
{
    private static ConfigEntry<int> _inventoryRows;
    private static ConfigEntry<int> _inventoryColumns;
    
    public static void Initialize(ConfigFile config)
    {
        _inventoryRows = config.Bind("Inventory", "Rows", 4,
            new ConfigDescription("Number of inventory rows",
                new AcceptableValueRange<int>(4, 10)));
        _inventoryColumns = config.Bind("Inventory", "Columns", 8,
            new ConfigDescription("Number of inventory columns",
                new AcceptableValueRange<int>(8, 20)));
    }
    
    [HarmonyPrefix]
    private static void Prefix(ref int w, ref int h)
    {
        w = _inventoryColumns.Value;
        h = _inventoryRows.Value;
    }
}
```

### Modify Item Weight

```csharp
[HarmonyPatch(typeof(Inventory), nameof(Inventory.GetTotalWeight))]
public class InventoryWeightPatch
{
    private static ConfigEntry<float> _weightMultiplier;
    
    public static void Initialize(ConfigFile config)
    {
        _weightMultiplier = config.Bind("Inventory", "WeightMultiplier", 0.5f,
            new ConfigDescription("Multiplier for item weight",
                new AcceptableValueRange<float>(0.0f, 2.0f)));
    }
    
    [HarmonyPostfix]
    private static void Postfix(ref float __result)
    {
        __result *= _weightMultiplier.Value;
    }
}
```

### Auto-Pickup Items

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.Update))]
public class AutoPickupPatch
{
    private static ConfigEntry<bool> _autoPickup;
    private static ConfigEntry<float> _pickupRadius;
    
    public static void Initialize(ConfigFile config)
    {
        _autoPickup = config.Bind("Pickup", "AutoPickup", true,
            "Automatically pickup nearby items");
        _pickupRadius = config.Bind("Pickup", "PickupRadius", 5f,
            new ConfigDescription("Radius for auto-pickup",
                new AcceptableValueRange<float>(1f, 20f)));
    }
    
    [HarmonyPostfix]
    private static void Postfix(Player __instance)
    {
        if (!_autoPickup.Value) return;
        if (__instance == null || !__instance.IsOwner()) return;
        
        var items = Object.FindObjectsOfType<ItemDrop>();
        foreach (var item in items)
        {
            if (item == null || item.m_itemData == null) continue;
            
            float distance = Vector3.Distance(__instance.transform.position, item.transform.position);
            if (distance <= _pickupRadius.Value)
            {
                __instance.Pickup(item.gameObject);
            }
        }
    }
}
```

---

## Combat Modifications

### Modify Damage Dealt

```csharp
[HarmonyPatch(typeof(Character), nameof(Character.Damage))]
public class DamageModifierPatch
{
    private static ConfigEntry<float> _damageMultiplier;
    
    public static void Initialize(ConfigFile config)
    {
        _damageMultiplier = config.Bind("Combat", "DamageMultiplier", 1.5f,
            new ConfigDescription("Damage multiplier for player",
                new AcceptableValueRange<float>(0.1f, 10f)));
    }
    
    [HarmonyPrefix]
    private static void Prefix(Character __instance, HitData hit)
    {
        // Only apply to player attacks
        if (hit.GetAttacker() is Player)
        {
            hit.m_damage.Modify(_damageMultiplier.Value);
        }
    }
}
```

### Modify Damage Taken

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.RPC_Damage))]
public class PlayerDamageReductionPatch
{
    private static ConfigEntry<float> _damageReduction;
    
    public static void Initialize(ConfigFile config)
    {
        _damageReduction = config.Bind("Combat", "DamageReduction", 0.5f,
            new ConfigDescription("Damage reduction (0.5 = 50% less damage)",
                new AcceptableValueRange<float>(0.0f, 1.0f)));
    }
    
    [HarmonyPrefix]
    private static void Prefix(HitData hit)
    {
        if (hit != null)
        {
            hit.m_damage.Modify(1f - _damageReduction.Value);
        }
    }
}
```

### No Durability Loss

```csharp
[HarmonyPatch(typeof(ItemDrop.ItemData), nameof(ItemDrop.ItemData.GetDurabilityPercentage))]
public class NoDurabilityLossPatch
{
    private static ConfigEntry<bool> _noDurabilityLoss;
    
    public static void Initialize(ConfigFile config)
    {
        _noDurabilityLoss = config.Bind("Items", "NoDurabilityLoss", false,
            "Prevent durability loss on items");
    }
    
    [HarmonyPostfix]
    private static void Postfix(ref float __result)
    {
        if (_noDurabilityLoss.Value)
        {
            __result = 1f; // Always 100% durability
        }
    }
}
```

---

## Custom Console Commands

### Basic Command

```csharp
using Jotunn.Entities;
using Jotunn.Managers;

private void RegisterCommands()
{
    CommandManager.Instance.AddConsoleCommand(new CustomCommand(
        name: "heal",
        description: "Heal the player to full health",
        action: (args) =>
        {
            var player = Player.m_localPlayer;
            if (player != null)
            {
                player.SetHealth(player.GetMaxHealth());
                Jotunn.Logger.LogInfo("Player healed to full health!");
            }
        }
    ));
}
```

### Command with Arguments

```csharp
private void RegisterCommands()
{
    CommandManager.Instance.AddConsoleCommand(new CustomCommand(
        name: "givegold",
        description: "Give gold coins. Usage: givegold <amount>",
        action: (args) =>
        {
            if (args.Length < 2)
            {
                Jotunn.Logger.LogWarning("Usage: givegold <amount>");
                return;
            }
            
            if (!int.TryParse(args[1], out int amount))
            {
                Jotunn.Logger.LogError("Invalid amount");
                return;
            }
            
            var player = Player.m_localPlayer;
            if (player != null && player.GetInventory() != null)
            {
                var coins = ObjectDB.instance.GetItemPrefab("Coins");
                if (coins != null)
                {
                    player.GetInventory().AddItem(coins.name, amount, 1, 0, 0, "");
                    Jotunn.Logger.LogInfo($"Added {amount} coins");
                }
            }
        }
    ));
}
```

---

## Configuration Examples

### Comprehensive Configuration

```csharp
public static class ModConfig
{
    // General
    public static ConfigEntry<bool> ModEnabled;
    
    // Player
    public static ConfigEntry<float> PlayerSpeedMultiplier;
    public static ConfigEntry<float> PlayerStaminaMultiplier;
    public static ConfigEntry<bool> InfiniteStamina;
    
    // Combat
    public static ConfigEntry<float> DamageMultiplier;
    public static ConfigEntry<float> DamageReduction;
    
    // Inventory
    public static ConfigEntry<int> InventoryRows;
    public static ConfigEntry<int> InventoryColumns;
    public static ConfigEntry<float> WeightMultiplier;
    
    public static void LoadConfig(ConfigFile config)
    {
        // General Section
        ModEnabled = config.Bind("General", "Enabled", true,
            "Enable or disable the mod entirely");
        
        // Player Section
        PlayerSpeedMultiplier = config.Bind("Player", "SpeedMultiplier", 1.0f,
            new ConfigDescription("Movement speed multiplier",
                new AcceptableValueRange<float>(0.1f, 5.0f)));
        
        PlayerStaminaMultiplier = config.Bind("Player", "StaminaMultiplier", 1.0f,
            new ConfigDescription("Stamina pool multiplier",
                new AcceptableValueRange<float>(0.1f, 10.0f)));
        
        InfiniteStamina = config.Bind("Player", "InfiniteStamina", false,
            "Enable infinite stamina (no stamina consumption)");
        
        // Combat Section
        DamageMultiplier = config.Bind("Combat", "DamageMultiplier", 1.0f,
            new ConfigDescription("Damage dealt multiplier",
                new AcceptableValueRange<float>(0.1f, 10.0f)));
        
        DamageReduction = config.Bind("Combat", "DamageReduction", 0.0f,
            new ConfigDescription("Damage reduction (0.5 = 50% less damage taken)",
                new AcceptableValueRange<float>(0.0f, 1.0f)));
        
        // Inventory Section
        InventoryRows = config.Bind("Inventory", "Rows", 4,
            new ConfigDescription("Number of inventory rows",
                new AcceptableValueRange<int>(4, 10)));
        
        InventoryColumns = config.Bind("Inventory", "Columns", 8,
            new ConfigDescription("Number of inventory columns",
                new AcceptableValueRange<int>(8, 20)));
        
        WeightMultiplier = config.Bind("Inventory", "WeightMultiplier", 1.0f,
            new ConfigDescription("Item weight multiplier (0.5 = half weight)",
                new AcceptableValueRange<float>(0.0f, 2.0f)));
    }
}
```

---

## Next Steps

- Review [Best Practices](BEST_PRACTICES.md) for code organization
- Study [Harmony Patching Guide](HARMONY_GUIDE.md) for advanced patching
- Check out the [mods/](../mods/) directory for complete working examples
- Join the [Valheim Modding Discord](https://discord.gg/RBq2mzeu4z) for help

## Additional Resources

- [Jotunn Examples](https://github.com/Valheim-Modding/JotunnModExample)
- [Valheim Modding Wiki](https://valheim-modding.github.io/Jotunn/)
- [Existing Valheim Mods](https://valheim.thunderstore.io/)
