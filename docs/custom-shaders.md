# Writing Custom Shaders

This guide explains how to create your own custom shaders for Ghostty.

## Shader Format

Ghostty shaders use **GLSL** (OpenGL Shading Language) and follow a **Shadertoy-compatible** format.

### Basic Structure

Every shader must have a `mainImage` function as its entry point:

```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Your shader code here
    fragColor = vec4(1.0, 0.0, 0.0, 1.0); // Output red
}
```

### Parameters

- `fragColor` - The output color for the current pixel (RGBA)
- `fragCoord` - The coordinates of the current pixel in screen space

## Available Uniforms

Ghostty provides these built-in uniforms:

| Uniform | Type | Description |
|---------|------|-------------|
| `iResolution` | `vec2` or `vec3` | Screen resolution in pixels |
| `iTime` | `float` | Elapsed time in seconds (for animations) |
| `iChannel0` | `sampler2D` | Terminal content texture |
| `iMouse` | `vec4` | Mouse position (optional) |
| `iFrame` | `int` | Frame counter (optional) |

## Example: Simple Shader

Here's a minimal shader that inverts colors:

```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 color = texture(iChannel0, uv);
    fragColor = vec4(1.0 - color.rgb, color.a);
}
```

## Common Patterns

### Reading Terminal Content

To sample the terminal content at the current pixel:

```glsl
vec2 uv = fragCoord / iResolution.xy;
vec4 terminalColor = texture(iChannel0, uv);
```

### Calculating Luminance

Useful for determining brightness of a pixel:

```glsl
float luminance(vec3 color) {
    return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
}
```

### Blending Effects with Terminal Content

Most shaders blend effects with the terminal while preserving text visibility:

```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 terminalColor = texture(iChannel0, uv);
    
    // Your effect color
    vec3 effectColor = vec3(0.0, 0.5, 1.0); // Blue
    
    // Create mask based on terminal brightness
    float lum = 0.299 * terminalColor.r + 0.587 * terminalColor.g + 0.114 * terminalColor.b;
    float mask = 1.0 - step(0.1, lum);
    
    // Blend: show effect in dark areas, terminal in bright areas
    vec3 result = mix(terminalColor.rgb, effectColor, mask * 0.5);
    
    fragColor = vec4(result, terminalColor.a);
}
```

### Animation with Time

Use `iTime` for animated effects:

```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    
    // Pulsing effect
    float pulse = 0.5 + 0.5 * sin(iTime * 2.0);
    
    vec4 color = texture(iChannel0, uv);
    fragColor = vec4(color.rgb * pulse, color.a);
}
```

### Hash/Random Functions

Common helper for procedural effects:

```glsl
float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec3 hash33(vec3 p) {
    p = fract(p * vec3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.xxy + p.yxx) * p.zyx);
}
```

## Configurable Parameters

Use `#define` for easy customization:

```glsl
#define INTENSITY 0.5
#define SPEED 2.0
#define COLOR vec3(0.2, 0.8, 0.4)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 color = texture(iChannel0, uv);
    
    float effect = sin(iTime * SPEED) * INTENSITY;
    fragColor = vec4(color.rgb + COLOR * effect, color.a);
}
```

## Performance Tips

1. **Minimize texture samples** - Each `texture()` call has a cost
2. **Avoid complex loops** - Keep iteration counts reasonable
3. **Use `step()` instead of `if`** - Branching can be expensive on GPUs
4. **Precompute constants** - Move calculations outside loops when possible

## Testing Your Shader

1. Save your shader as `~/.config/ghostty/shaders/custom.glsl`
2. Update your Ghostty config:
   ```ini
   custom-shader = ~/.config/ghostty/shaders/custom.glsl
   ```
3. Restart Ghostty to see the effect

## Resources

- [The Book of Shaders](https://thebookofshaders.com/) - Excellent GLSL tutorial
- [Shadertoy](https://www.shadertoy.com/) - Inspiration and examples
- [GLSL Reference](https://www.khronos.org/opengl/wiki/OpenGL_Shading_Language) - Official documentation
