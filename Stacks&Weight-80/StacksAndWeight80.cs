using BepInEx;
using BepInEx.Logging;
using HarmonyLib;

namespace StacksAndWeight80
{
    [BepInPlugin(PluginGUID, PluginName, PluginVersion)]
    public class StacksAndWeight80 : BaseUnityPlugin
    {
        public const string PluginGUID = "com.shifty81.stacksandweight80";
        public const string PluginName = "Stacks & Weight -80%";
        public const string PluginVersion = "1.0.0";

        internal static ManualLogSource Log;
        private Harmony _harmony;

        private void Awake()
        {
            Log = Logger;
            Log.LogInfo($"{PluginName} v{PluginVersion} is loading...");

            _harmony = new Harmony(PluginGUID);
            _harmony.PatchAll();

            Log.LogInfo($"{PluginName} loaded successfully!");
        }

        private void OnDestroy()
        {
            _harmony?.UnpatchSelf();
        }
    }
}
