# Community Resources

A curated list of helpful resources, repositories, tools, and communities for Valheim modding.

## Table of Contents
- [Official Documentation](#official-documentation)
- [GitHub Repositories](#github-repositories)
- [Mod Repositories](#mod-repositories)
- [Tools and Utilities](#tools-and-utilities)
- [Communities](#communities)
- [Video Tutorials](#video-tutorials)
- [Articles and Guides](#articles-and-guides)

---

## Official Documentation

### BepInEx
- **[BepInEx Documentation](https://docs.bepinex.dev/)** - Official BepInEx documentation
- **[BepInEx GitHub](https://github.com/BepInEx/BepInEx)** - Source code and releases
- **[BepInEx Discord](https://discord.gg/MpFEDAg)** - Official support server

### Jotunn
- **[Jotunn Documentation](https://valheim-modding.github.io/Jotunn/)** - Comprehensive API documentation
- **[Jotunn GitHub](https://github.com/Valheim-Modding/Jotunn)** - Source code and examples
- **[Jotunn Wiki](https://valheim-modding.github.io/Jotunn/tutorials/overview.html)** - Tutorials and guides

### Harmony
- **[Harmony Documentation](https://harmony.pardeike.net/)** - Official Harmony documentation
- **[Harmony GitHub](https://github.com/pardeike/Harmony)** - Source code
- **[Harmony Wiki](https://github.com/pardeike/Harmony/wiki)** - Usage examples

---

## GitHub Repositories

### Templates and Examples

#### **JotunnModStub** ⭐ Recommended
- **URL:** https://github.com/Valheim-Modding/JotunnModStub
- **Description:** Official Jotunn mod template with best practices
- **Use Case:** Starting point for new mods
- **Features:**
  - Pre-configured build system
  - Environment variable handling
  - Example configuration
  - Thunderstore packaging setup

#### **JotunnModExample**
- **URL:** https://github.com/Valheim-Modding/JotunnModExample
- **Description:** Comprehensive example showing all Jotunn features
- **Use Case:** Learning how to use Jotunn APIs
- **Features:**
  - Custom items, recipes, creatures
  - Localization examples
  - Network synchronization
  - Asset bundle usage

#### **ModTemplateValheim**
- **URL:** https://github.com/Measurity/ModTemplateValheim
- **Description:** Alternative mod template by Measurity
- **Use Case:** Quick start without Jotunn dependency
- **Features:**
  - Cross-platform build scripts
  - Assembly publicizer integration
  - Clean project structure

#### **ExampleMod** (Archived)
- **URL:** https://github.com/Valheim-Modding/ExampleMod
- **Description:** Legacy example mod
- **Use Case:** Reference for basic BepInEx plugin structure
- **Note:** Use JotunnModStub for new projects

### Popular Mod Repositories

#### **ValheimLib** (Legacy)
- **URL:** https://github.com/Valheim-Modding/ValheimLib
- **Description:** Predecessor to Jotunn (now deprecated)
- **Note:** Replaced by Jotunn - use for historical reference only

#### **Digitalroot's Valheim Mods**
- **URL:** https://github.com/Digitalroot-Valheim
- **Description:** Collection of well-structured mods by prolific modder
- **Use Case:** Study real-world mod implementations
- **Notable Mods:**
  - Advanced Building Mode
  - Slope Combat Assistance
  - Various QoL improvements

#### **Azumatt's Mods**
- **URL:** https://github.com/AzumattDev
- **Description:** High-quality mods with clean code
- **Use Case:** Learn advanced modding techniques
- **Notable Mods:**
  - Official Expansions support
  - Server-side mods
  - Complex game mechanics

### Utility Repositories

#### **AssemblyPublicizer**
- **URL:** https://github.com/BepInEx/BepInEx.AssemblyPublicizer
- **Description:** Tool to make internal/private game code accessible
- **Use Case:** Required for accessing Valheim's internal classes

#### **HookGenPatcher**
- **URL:** https://github.com/harbingerofme/Bepinex.Monomod.HookGenPatcher
- **Description:** Generates event hooks for easier patching
- **Use Case:** Alternative to Harmony for some use cases

---

## Mod Repositories

### Thunderstore
- **URL:** https://valheim.thunderstore.io/
- **Description:** Primary mod repository for Valheim
- **Features:**
  - Easy mod installation via mod manager
  - Dependency management
  - Version control
  - Community ratings

### Nexus Mods
- **URL:** https://www.nexusmods.com/valheim
- **Description:** Alternative mod repository
- **Features:**
  - Large mod community
  - Mod collections
  - Manual downloads
  - Detailed mod pages

---

## Tools and Utilities

### Development Tools

#### **dnSpy**
- **URL:** https://github.com/dnSpy/dnSpy
- **Description:** .NET debugger and assembly editor
- **Use Case:** Reverse-engineering game code, debugging
- **Features:**
  - Decompile .NET assemblies
  - Set breakpoints in game code
  - Edit and recompile assemblies

#### **ILSpy**
- **URL:** https://github.com/icsharpcode/ILSpy
- **Description:** .NET decompiler
- **Use Case:** Browse and understand game code
- **Features:**
  - Fast decompilation
  - Multiple language output
  - Cross-reference navigation

#### **Unity Asset Bundle Extractor (UABE)**
- **URL:** https://github.com/SeriousCache/UABE
- **Description:** Unity asset bundle viewer/editor
- **Use Case:** Extract and view game assets
- **Features:**
  - View textures, meshes, audio
  - Extract assets
  - Modify asset bundles

#### **AssetStudio**
- **URL:** https://github.com/Perfare/AssetStudio
- **Description:** Unity asset viewer and exporter
- **Use Case:** Browse and export game assets
- **Features:**
  - Multiple asset format support
  - Batch export
  - Preview assets

### Mod Management

#### **r2modman**
- **URL:** https://thunderstore.io/c/valheim/p/ebkr/r2modman/
- **Description:** Cross-platform mod manager
- **Use Case:** Installing and managing mods
- **Features:**
  - One-click mod installation
  - Profile management
  - Automatic updates
  - Dependency resolution

#### **Thunderstore Mod Manager**
- **URL:** https://www.overwolf.com/app/Thunderstore-Thunderstore_Mod_Manager
- **Description:** Overwolf-based mod manager
- **Use Case:** Alternative to r2modman
- **Features:**
  - Integrated with Overwolf
  - Easy mod browsing
  - Automatic installation

### Development Extensions

#### **Visual Studio Tools**
- **C# Extensions** - Enhanced C# support
- **GitHub Extension** - Git integration
- **Visual Studio Tools for Unity** - Unity API documentation

#### **VS Code Extensions**
- **C# Dev Kit** - C# language support
- **Unity Tools** - Unity development helpers
- **GitLens** - Enhanced Git features

---

## Communities

### Discord Servers

#### **Valheim Modding**
- **Invite:** https://discord.gg/RBq2mzeu4z
- **Description:** Official Valheim modding community
- **Channels:**
  - Mod development help
  - Jotunn support
  - Mod showcase
  - General discussion

#### **BepInEx Discord**
- **Invite:** https://discord.gg/MpFEDAg
- **Description:** BepInEx framework support
- **Use Case:** BepInEx-specific questions

### Reddit

#### **/r/ValheimMods**
- **URL:** https://www.reddit.com/r/ValheimMods/
- **Description:** Valheim modding subreddit
- **Content:**
  - Mod releases
  - Mod requests
  - Troubleshooting help

### Forums

#### **Steam Community Hub**
- **URL:** https://steamcommunity.com/app/892970/discussions/
- **Description:** Official Valheim discussions
- **Note:** Modding subforum available

#### **Thunderstore Community**
- **URL:** https://thunderstore.io/c/valheim/
- **Description:** Community around Thunderstore mods
- **Features:**
  - Mod discussions
  - Support threads

---

## Video Tutorials

### YouTube Channels

#### **GamerPoets**
- **URL:** https://www.youtube.com/@gamerpoets
- **Content:** Modding tutorials for various games including Valheim
- **Recommended Videos:**
  - "Modding Foundation || How to Mod Valheim"
  - BepInEx installation guides

#### **Unity Official**
- **URL:** https://www.youtube.com/@unity
- **Content:** Unity engine tutorials
- **Use Case:** Understanding Unity concepts for modding

### Specific Tutorial Videos

#### Beginner Tutorials
- **"How to Install Valheim Mods"** - Basic mod installation
- **"BepInEx Setup Guide"** - Installing the framework
- **"Creating Your First Valheim Mod"** - Basic mod creation

#### Advanced Tutorials
- **"Harmony Patching Tutorial"** - Runtime code patching
- **"Custom Items with Jotunn"** - Adding custom content
- **"Unity Asset Bundles"** - Working with custom assets

---

## Articles and Guides

### Modding Guides

#### **Valtools Wiki**
- **URL:** https://valtools.org/wiki.php
- **Content:**
  - Best practices for mod development
  - Common patterns and solutions
  - Performance optimization tips
- **Recommended Pages:**
  - [Best Practices](https://valtools.org/wiki.php?page=Best-Practices)
  - Harmony patching examples

#### **Jotunn Tutorials**
- **URL:** https://valheim-modding.github.io/Jotunn/tutorials/overview.html
- **Content:**
  - Step-by-step guides
  - API usage examples
  - Common scenarios

### Technical Articles

#### **Unity Scripting Reference**
- **URL:** https://docs.unity3d.com/ScriptReference/
- **Content:** Unity API documentation
- **Use Case:** Understanding Unity objects in Valheim

#### **C# Documentation**
- **URL:** https://learn.microsoft.com/en-us/dotnet/csharp/
- **Content:** C# language reference
- **Use Case:** Learning C# for mod development

#### **BepInEx Plugin Tutorial**
- **URL:** https://docs.bepinex.dev/articles/dev_guide/plugin_tutorial/
- **Content:** Creating BepInEx plugins
- **Use Case:** Understanding plugin fundamentals

---

## Helpful Websites

### **Valheim Wiki**
- **URL:** https://valheim.fandom.com/
- **Content:** Game mechanics, items, creatures
- **Use Case:** Understanding game systems to mod them

### **GitHub Valheim-Modding Organization**
- **URL:** https://github.com/Valheim-Modding
- **Content:** Official modding resources
- **Repositories:**
  - Jotunn library
  - Templates and examples
  - Community tools

### **NexusMods Valheim**
- **URL:** https://www.nexusmods.com/valheim
- **Content:** Mod repository and community
- **Features:**
  - Mod descriptions
  - Installation guides
  - User reviews

---

## Contributing to Community

### Share Your Mods
- Upload to Thunderstore or Nexus Mods
- Share on Reddit and Discord
- Create detailed documentation

### Contribute to Libraries
- Submit PRs to Jotunn
- Report bugs
- Improve documentation

### Help Others
- Answer questions in Discord
- Write tutorials and guides
- Share code examples

---

## Recommended Learning Path

### For Beginners
1. Learn C# basics
2. Install Visual Studio and set up development environment
3. Follow [Development Setup Guide](DEVELOPMENT_SETUP.md)
4. Clone JotunnModStub and build your first mod
5. Study [Code Examples](EXAMPLES.md)
6. Join Valheim Modding Discord for support

### For Intermediate Developers
1. Study [Best Practices](BEST_PRACTICES.md)
2. Learn Harmony patching from [Harmony Guide](HARMONY_GUIDE.md)
3. Explore JotunnModExample for advanced features
4. Create mods with custom items and recipes
5. Study existing popular mods

### For Advanced Developers
1. Reverse-engineer game code with dnSpy
2. Create asset bundles with Unity
3. Implement complex game mechanics
4. Contribute to Jotunn or other libraries
5. Create comprehensive mods with networking

---

## Stay Updated

- **Follow** Valheim-Modding on GitHub
- **Watch** Thunderstore for new mod releases
- **Join** Discord for announcements
- **Subscribe** to Valheim subreddit
- **Check** official Valheim patch notes for game updates

---

## Next Steps

- Start with [Development Setup](DEVELOPMENT_SETUP.md) to configure your environment
- Review [Best Practices](BEST_PRACTICES.md) for coding guidelines
- Study [Code Examples](EXAMPLES.md) for practical implementations
- Explore the [mods/](../mods/) directory in this repository

Happy modding! 🛠️⚔️
