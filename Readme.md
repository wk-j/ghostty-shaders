# Ghostty Shaders

A collection of custom shaders for [Ghostty](https://ghostty.org) terminal emulator.

## Installation

Clone the repository:

```sh
git clone --depth 1 https://github.com/hackr-sh/ghostty-shaders
cd ghostty-shaders
```

Copy your preferred shader file to the Ghostty config directory:

```sh
cp <your-choice>.glsl ~/.config/ghostty/shaders/shader.glsl
```

Add the following line to your `~/.config/ghostty/config` file to enable the custom shader:

```ini
custom-shader = ~/.config/ghostty/shaders/shader.glsl
```

## Available Shaders

### Effects & Filters

| Shader | Description |
|--------|-------------|
| `animated-gradient-shader.glsl` | Animated gradient background effect |
| `bloom.glsl` | Bloom/glow post-processing effect |
| `dither.glsl` | Dithering effect |
| `glitchy.glsl` | Glitch/distortion effect |
| `glow-rgbsplit-twitchy.glsl` | RGB split with glow and twitch |
| `negative.glsl` | Inverted colors effect |
| `spotlight.glsl` | Spotlight/vignette effect |

### CRT & Retro

| Shader | Description |
|--------|-------------|
| `bettercrt.glsl` | Enhanced CRT monitor simulation |
| `crt.glsl` | Classic CRT monitor effect |
| `in-game-crt.glsl` | In-game style CRT effect |
| `in-game-crt-cursor.glsl` | In-game CRT with cursor effects |
| `retro-terminal.glsl` | Retro terminal styling |
| `tft.glsl` | TFT display simulation |

### Backgrounds & Ambient

| Shader | Description |
|--------|-------------|
| `cineShader-Lava.glsl` | Lava/magma background effect |
| `cubes.glsl` | 3D cubes background |
| `drunkard.glsl` | Wavy distortion effect |
| `fireworks.glsl` | Fireworks animation |
| `fireworks-rockets.glsl` | Fireworks with rocket trails |
| `galaxy.glsl` | Galaxy/space background |
| `gears-and-belts.glsl` | Mechanical gears animation |
| `gradient-background.glsl` | Static gradient background |
| `inside-the-matrix.glsl` | Matrix-style rain effect |
| `just-snow.glsl` | Snowfall effect |
| `matrix-hallway.glsl` | Matrix hallway tunnel |
| `mnoise.glsl` | Noise pattern effect |
| `sin-interference.glsl` | Sine wave interference pattern |
| `smoke-and-ghost.glsl` | Smoke and ghosting effect |
| `sparks-from-fire.glsl` | Fire sparks animation |
| `starfield.glsl` | Starfield background |
| `starfield-colors.glsl` | Colorful starfield background |
| `underwater.glsl` | Underwater effect |
| `water.glsl` | Water surface effect |

### Cursor Effects

| Shader | Description |
|--------|-------------|
| `cursor_blaze.glsl` | Blazing cursor trail |

### Fancy Cursor Effects

Located in the `fancy/` directory, these shaders provide enhanced cursor animations:

| Shader | Description |
|--------|-------------|
| `fancy/cursor_blaze_fancy.glsl` | Enhanced blazing cursor |
| `fancy/cursor_sweep.glsl` | Sweeping cursor effect |
| `fancy/cursor_tail.glsl` | Cursor with trailing effect |
| `fancy/cursor_warp.glsl` | Warping cursor effect |
| `fancy/rectangle_boom_cursor.glsl` | Exploding rectangle cursor |
| `fancy/ripple_cursor.glsl` | Ripple effect on cursor |
| `fancy/ripple_rectangle_cursor.glsl` | Rectangle ripple cursor |
| `fancy/sonic_boom_cursor.glsl` | Sonic boom cursor effect |

## Previews

Some shaders have preview images available in the `theme/` directory.

## Documentation

See the `docs/` directory for more information:
- [Custom Shaders Guide](docs/custom-shaders.md)
- [Shaders Overview](docs/shaders.md)
- [Troubleshooting](docs/troubleshooting.md)

## License

See individual shader files for license information.
