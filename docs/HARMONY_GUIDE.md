# Harmony Patching Guide

A comprehensive guide to using Harmony for runtime code patching in Valheim mods.

## Table of Contents
- [What is Harmony?](#what-is-harmony)
- [Patch Types](#patch-types)
- [Basic Setup](#basic-setup)
- [Advanced Techniques](#advanced-techniques)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)

---

## What is Harmony?

**Harmony** is a library for patching, replacing, and decorating .NET methods during runtime. It's essential for modifying game behavior without changing original game files.

### Key Features

- **Non-destructive**: Doesn't modify original game files
- **Coexistence**: Multiple mods can patch the same method
- **Reversible**: Patches can be removed at runtime
- **Powerful**: Can completely replace or augment method behavior

### When to Use Harmony

- Modify existing game mechanics
- Add functionality to existing classes
- Change how game systems work
- React to game events not exposed by APIs

---

## Patch Types

### Prefix Patches

Runs **before** the original method. Can prevent the original method from executing.

**Use Cases:**
- Validation before method execution
- Preventing certain actions
- Modifying input parameters
- Early returns

**Example:**
```csharp
[HarmonyPatch(typeof(Player), nameof(Player.TakeDamage))]
public class PlayerTakeDamagePatch
{
    [HarmonyPrefix]
    private static bool Prefix(Player __instance, HitData hit)
    {
        // Make player invulnerable if they have a specific status effect
        if (__instance.GetSEMan().HaveStatusEffect("Invulnerable"))
        {
            return false; // Skip the original TakeDamage method
        }
        
        // Reduce damage by 50%
        hit.m_damage.Modify(0.5f);
        
        return true; // Continue to original method
    }
}
```

**Important:**
- Return `true` to execute the original method
- Return `false` to skip the original method
- Can modify method parameters (they're passed by reference)

### Postfix Patches

Runs **after** the original method completes.

**Use Cases:**
- React to method completion
- Modify return values
- Perform cleanup or additional logic
- Logging and debugging

**Example:**
```csharp
[HarmonyPatch(typeof(Inventory), nameof(Inventory.GetTotalWeight))]
public class InventoryWeightPatch
{
    [HarmonyPostfix]
    private static void Postfix(Inventory __instance, ref float __result)
    {
        // Reduce effective weight by 50%
        __result *= 0.5f;
    }
}
```

**Special Parameters:**
- `__result`: The return value (use `ref` to modify it)
- `__state`: State passed from Prefix (via out parameter)
- `__instance`: The instance being patched (for non-static methods)

### Transpiler Patches

Modifies the **Intermediate Language (IL)** code of the method.

**Use Cases:**
- Precise surgical changes to method logic
- Performance optimizations
- Complex behavior modifications
- When Prefix/Postfix aren't sufficient

**Example:**
```csharp
using System.Collections.Generic;
using System.Reflection.Emit;
using HarmonyLib;

[HarmonyPatch(typeof(Player), nameof(Player.GetJogSpeedFactor))]
public class PlayerSpeedPatch
{
    [HarmonyTranspiler]
    private static IEnumerable<CodeInstruction> Transpiler(IEnumerable<CodeInstruction> instructions)
    {
        var codes = new List<CodeInstruction>(instructions);
        
        for (int i = 0; i < codes.Count; i++)
        {
            // Find where speed multiplier is loaded (example)
            if (codes[i].opcode == OpCodes.Ldc_R4 && (float)codes[i].operand == 1.0f)
            {
                // Replace with 1.5x speed
                codes[i].operand = 1.5f;
            }
        }
        
        return codes;
    }
}
```

**Warning:** Transpilers are complex and fragile. Use Prefix/Postfix when possible.

### Finalizer Patches

Always runs, even if exceptions occur.

**Use Cases:**
- Exception handling
- Guaranteed cleanup
- Error recovery

**Example:**
```csharp
[HarmonyPatch(typeof(Player), nameof(Player.Save))]
public class PlayerSavePatch
{
    [HarmonyFinalizer]
    private static Exception Finalizer(Exception __exception)
    {
        if (__exception != null)
        {
            Jotunn.Logger.LogError($"Error saving player: {__exception.Message}");
            // Return null to suppress the exception, or return __exception to propagate it
            return null;
        }
        return null;
    }
}
```

---

## Basic Setup

### 1. Initialize Harmony

```csharp
using BepInEx;
using HarmonyLib;

[BepInPlugin(PluginGUID, PluginName, PluginVersion)]
public class MyMod : BaseUnityPlugin
{
    private const string PluginGUID = "com.author.mymod";
    private const string PluginName = "MyMod";
    private const string PluginVersion = "1.0.0";

    private Harmony _harmony;

    private void Awake()
    {
        // Create Harmony instance with unique ID
        _harmony = new Harmony(PluginGUID);
        
        // Apply all patches in the assembly
        _harmony.PatchAll();
        
        // Or patch specific type
        // _harmony.PatchAll(typeof(MyPatches));
    }

    private void OnDestroy()
    {
        // Clean up patches when mod is unloaded
        _harmony?.UnpatchSelf();
    }
}
```

### 2. Create Patch Classes

Organize patches by the game class they modify:

```csharp
// PlayerPatches.cs
[HarmonyPatch(typeof(Player))]
public class PlayerPatches
{
    [HarmonyPatch(nameof(Player.Update))]
    [HarmonyPostfix]
    private static void Update_Postfix(Player __instance)
    {
        // Patch logic
    }
    
    [HarmonyPatch(nameof(Player.TakeDamage))]
    [HarmonyPrefix]
    private static bool TakeDamage_Prefix(Player __instance, HitData hit)
    {
        // Patch logic
        return true;
    }
}
```

### 3. Specify Method Signatures for Overloads

When patching overloaded methods:

```csharp
[HarmonyPatch(typeof(Inventory), nameof(Inventory.AddItem),
    new Type[] { typeof(ItemDrop.ItemData), typeof(int), typeof(int), typeof(int) })]
public class InventoryAddItemPatch
{
    [HarmonyPrefix]
    private static bool Prefix(ItemDrop.ItemData item, int x, int y, int amount)
    {
        // Patch logic for specific overload
        return true;
    }
}
```

---

## Advanced Techniques

### Accessing Private Fields

Use `__instance` and reflection or Harmony's `AccessTools`:

```csharp
[HarmonyPatch(typeof(Character), nameof(Character.Damage))]
public class CharacterDamagePatch
{
    [HarmonyPostfix]
    private static void Postfix(Character __instance)
    {
        // Using AccessTools
        var healthField = AccessTools.Field(typeof(Character), "m_health");
        float health = (float)healthField.GetValue(__instance);
        
        // Or use Traverse (easier)
        float health2 = Traverse.Create(__instance).Field("m_health").GetValue<float>();
        
        Jotunn.Logger.LogInfo($"Character health: {health}");
    }
}
```

### Passing State Between Prefix and Postfix

Use `__state` parameter:

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.EatFood))]
public class PlayerEatFoodPatch
{
    [HarmonyPrefix]
    private static void Prefix(Player __instance, out float __state)
    {
        // Store current health in __state
        __state = __instance.GetHealth();
    }
    
    [HarmonyPostfix]
    private static void Postfix(Player __instance, float __state)
    {
        // Compare with stored health
        float healthGained = __instance.GetHealth() - __state;
        Jotunn.Logger.LogInfo($"Health gained from food: {healthGained}");
    }
}
```

### Patching Constructors

```csharp
[HarmonyPatch(typeof(Character), MethodType.Constructor)]
public class CharacterConstructorPatch
{
    [HarmonyPostfix]
    private static void Postfix(Character __instance)
    {
        Jotunn.Logger.LogInfo($"Character created: {__instance.name}");
    }
}
```

### Patching Property Getters/Setters

```csharp
[HarmonyPatch(typeof(Player))]
public class PlayerPropertyPatch
{
    [HarmonyPatch(nameof(Player.InGodMode), MethodType.Getter)]
    [HarmonyPostfix]
    private static void GetGodMode_Postfix(ref bool __result)
    {
        // Always return true for god mode
        __result = true;
    }
}
```

### Conditional Patching

```csharp
private void Awake()
{
    _harmony = new Harmony(PluginGUID);
    
    // Only patch if configuration is enabled
    if (ModConfig.EnableDamageModification.Value)
    {
        _harmony.Patch(
            AccessTools.Method(typeof(Character), nameof(Character.Damage)),
            postfix: new HarmonyMethod(typeof(CharacterDamagePatch), nameof(CharacterDamagePatch.Postfix))
        );
    }
}
```

---

## Common Patterns

### Pattern 1: Modifying Method Return Values

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.GetMaxCarryWeight))]
public class PlayerCarryWeightPatch
{
    [HarmonyPostfix]
    private static void Postfix(ref float __result)
    {
        __result *= 2.0f; // Double carry weight
    }
}
```

### Pattern 2: Preventing Actions

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.ConsumeResources))]
public class NoResourceConsumptionPatch
{
    [HarmonyPrefix]
    private static bool Prefix()
    {
        // Prevent all resource consumption
        return false;
    }
}
```

### Pattern 3: Adding Side Effects

```csharp
[HarmonyPatch(typeof(Player), nameof(Player.OnDeath))]
public class PlayerDeathPatch
{
    [HarmonyPostfix]
    private static void Postfix(Player __instance)
    {
        // Custom behavior on player death
        MessageHud.instance.ShowMessage(MessageHud.MessageType.Center, "You have died!");
        
        // Drop custom items, spawn effects, etc.
    }
}
```

### Pattern 4: Modifying Collections

```csharp
[HarmonyPatch(typeof(ObjectDB), nameof(ObjectDB.Awake))]
public class ObjectDBPatch
{
    [HarmonyPostfix]
    private static void Postfix(ObjectDB __instance)
    {
        // Add custom items to the game database
        var customItems = LoadCustomItems();
        foreach (var item in customItems)
        {
            __instance.m_items.Add(item);
        }
    }
}
```

---

## Troubleshooting

### Patch Not Applying

**Check:**
1. Patch method is static
2. Class and method signatures match exactly
3. Method exists in the target class
4. Harmony initialization happened before game code runs

**Debug:**
```csharp
_harmony.PatchAll();
Jotunn.Logger.LogInfo($"Patched methods: {_harmony.GetPatchedMethods().Count()}");
foreach (var method in _harmony.GetPatchedMethods())
{
    Jotunn.Logger.LogInfo($"Patched: {method.DeclaringType}.{method.Name}");
}
```

### Ambiguous Method Match

**Error:** "Ambiguous match found"

**Solution:** Specify parameter types:
```csharp
[HarmonyPatch(typeof(Inventory), nameof(Inventory.AddItem),
    new Type[] { typeof(ItemDrop.ItemData) })]
```

### Null Reference Exceptions

**Always validate:**
```csharp
[HarmonyPostfix]
private static void Postfix(Player __instance)
{
    if (__instance == null) return;
    if (!__instance.IsOwner()) return;
    
    // Safe to use __instance
}
```

### Performance Issues

**Avoid patching frequently-called methods:**
- `Update()`, `FixedUpdate()`, `LateUpdate()`
- Rendering methods
- Input polling methods

**If you must, keep logic minimal:**
```csharp
private static int frameCounter = 0;

[HarmonyPatch(typeof(Player), nameof(Player.Update))]
[HarmonyPostfix]
private static void Update_Postfix()
{
    // Only run every 60 frames
    if (++frameCounter % 60 != 0) return;
    
    // Your logic here
}
```

### Conflicts with Other Mods

**Use unique Harmony IDs:**
```csharp
private Harmony _harmony = new Harmony("com.yourname.yourmod.unique");
```

**Check for conflicts:**
```csharp
var patches = Harmony.GetPatchInfo(targetMethod);
if (patches != null)
{
    Jotunn.Logger.LogInfo($"Method {targetMethod.Name} has {patches.Prefixes.Count} prefixes");
}
```

---

## Best Practices Summary

1. ✅ **Always use static methods** for patches
2. ✅ **Validate instances** before accessing them
3. ✅ **Use meaningful names** for patch methods
4. ✅ **Specify signatures** for overloaded methods
5. ✅ **Keep patches lightweight**, especially in Update loops
6. ✅ **Unpatch on mod unload** to prevent issues
7. ✅ **Log important events** for debugging
8. ✅ **Test with other mods** to ensure compatibility

## Additional Resources

- [Official Harmony Documentation](https://harmony.pardeike.net/)
- [Harmony GitHub](https://github.com/pardeike/Harmony)
- [BepInEx Harmony Guide](https://docs.bepinex.dev/master/articles/dev_guide/runtime_patching.html)
- [Valtools Best Practices](https://valtools.org/wiki.php?page=Best-Practices)

---

## Next Steps

- Study [Code Examples](EXAMPLES.md) for practical Harmony usage
- Review [Best Practices](BEST_PRACTICES.md) for overall mod development
- Explore existing Valheim mods on [GitHub](https://github.com/Valheim-Modding) for real-world examples
