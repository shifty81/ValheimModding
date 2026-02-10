using HarmonyLib;

namespace StacksAndWeight80.Patches
{
    /// <summary>
    /// Patches ObjectDB.Awake to modify all item shared data:
    /// - Reduces weight by 80% (multiplies by 0.2) for every item that has weight > 0
    /// - Sets max stack size to 500 for every resource (items with max stack > 1)
    /// </summary>
    [HarmonyPatch(typeof(ObjectDB), nameof(ObjectDB.Awake))]
    public class ItemDataPatches
    {
        private const float WeightMultiplier = 0.2f;
        private const int ResourceStackSize = 500;

        [HarmonyPostfix]
        private static void Postfix(ObjectDB __instance)
        {
            if (__instance == null || __instance.m_items == null)
                return;

            int weightModified = 0;
            int stackModified = 0;

            foreach (var prefab in __instance.m_items)
            {
                if (prefab == null)
                    continue;

                var itemDrop = prefab.GetComponent<ItemDrop>();
                if (itemDrop == null || itemDrop.m_itemData == null)
                    continue;

                var shared = itemDrop.m_itemData.m_shared;

                // Cut weight by 80% on every item that has a weight
                if (shared.m_weight > 0f)
                {
                    shared.m_weight *= WeightMultiplier;
                    weightModified++;
                }

                // Increase stacks to 500 for every resource (stackable items)
                if (shared.m_maxStackSize > 1)
                {
                    shared.m_maxStackSize = ResourceStackSize;
                    stackModified++;
                }
            }

            StacksAndWeight80.Log.LogInfo(
                $"Modified {weightModified} items (weight x{WeightMultiplier}) " +
                $"and {stackModified} resources (stack size -> {ResourceStackSize})");
        }
    }
}
