# Ghostty Shaders

A community-curated collection of custom GLSL shaders for [Ghostty](https://github.com/ghostty-org/ghostty), a GPU-accelerated terminal emulator.

## Overview

This repository contains **32 shader files** that add visual effects to your Ghostty terminal, ranging from retro CRT aesthetics to animated backgrounds like fireworks, starfields, and matrix effects.

## Quick Start

1. Clone the repository:
   ```sh
   git clone --depth 1 https://github.com/hackr-sh/ghostty-shaders
   cd ghostty-shaders
   ```

2. Copy your preferred shader to the Ghostty config directory:
   ```sh
   cp <shader-name>.glsl ~/.config/ghostty/shaders/shader.glsl
   ```

3. Add to your `~/.config/ghostty/config`:
   ```ini
   custom-shader = ~/.config/ghostty/shaders/shader.glsl
   ```

4. Restart Ghostty to see the effect.

## Documentation

- [Shader Catalog](shaders.md) - Complete list of all available shaders
- [Writing Custom Shaders](custom-shaders.md) - Guide to creating your own shaders
- [Troubleshooting](troubleshooting.md) - Common issues and solutions

## Preview

Some shaders have preview images available in the `theme/` directory.

| Shader | Preview |
|--------|---------|
| bettercrt | ![bettercrt](../theme/bettercrt.png) |
| bloom | ![bloom](../theme/bloom.png) |
| crt | ![crt](../theme/crt.png) |
| cubes | ![cubes](../theme/cubes.png) |
| dither | ![dither](../theme/dither.png) |
| drunkard | ![drunkard](../theme/drunkard.png) |
| fireworks | ![fireworks](../theme/fireworks.png) |
| fireworks-rockets | ![fireworks-rockets](../theme/fireworks-rocket.png) |
| gears-and-belts | ![gears-and-belts](../theme/gears-and-belts.png) |
| glitchy | ![glitchy](../theme/glitchy.png) |
| cineShader-Lava | ![cineShader-Lava](../theme/cineShader-Lava.png) |

## Contributing

Contributions are welcome! Feel free to submit pull requests with new shaders or improvements to existing ones.

## License

Individual shaders may have their own licenses. Check the header comments in each shader file for specific licensing information.
