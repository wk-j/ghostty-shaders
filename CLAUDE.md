# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a collection of GLSL shaders for the [Ghostty](https://ghostty.org) terminal emulator. Shaders are visual effects applied to the terminal display, ranging from CRT effects and backgrounds to cursor animations.

## Shader Architecture

### Format
All shaders use GLSL with a **Shadertoy-compatible** format. Every shader must have a `mainImage` entry point:

```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // fragColor = output RGBA color for current pixel
    // fragCoord = screen coordinates of current pixel
}
```

### Available Uniforms

| Uniform | Type | Description |
|---------|------|-------------|
| `iResolution` | `vec2`/`vec3` | Screen resolution in pixels |
| `iTime` | `float` | Elapsed time in seconds |
| `iChannel0` | `sampler2D` | Terminal content texture |
| `iMouse` | `vec4` | Mouse position (optional) |
| `iFrame` | `int` | Frame counter (optional) |

### Cursor Effect Uniforms (fancy/ shaders)
Fancy cursor shaders have access to additional uniforms:
- `iCurrentCursor` - vec4 with current cursor position and dimensions
- `iPreviousCursor` - vec4 with previous cursor position and dimensions
- `iTimeCursorChange` - float timestamp of last cursor movement

### Common Patterns

**Reading terminal content:**
```glsl
vec2 uv = fragCoord / iResolution.xy;
vec4 terminalColor = texture(iChannel0, uv);
```

**Blending effects while preserving text:**
Use luminance masking to show effects in dark areas and terminal text in bright areas.

**Configurable parameters:**
Use `#define` at the top of shader files for easy customization.

## Directory Structure

- Root directory: Standard effect shaders (CRT, bloom, backgrounds, etc.)
- `fancy/`: Enhanced cursor effect shaders with particle systems and trails
- `docs/`: Documentation for writing custom shaders
- `theme/`: Preview images for some shaders

## Testing Shaders

1. Copy shader to `~/.config/ghostty/shaders/`
2. Add to Ghostty config: `custom-shader = ~/.config/ghostty/shaders/shader.glsl`
3. Restart Ghostty to see changes
