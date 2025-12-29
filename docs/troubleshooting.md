# Troubleshooting

Common issues and solutions when using Ghostty shaders.

## Shader Not Loading

### Check file path
Ensure your config points to the correct file:

```ini
custom-shader = ~/.config/ghostty/shaders/shader.glsl
```

Verify the file exists:
```sh
ls ~/.config/ghostty/shaders/shader.glsl
```

### Check file permissions
Make sure the shader file is readable:
```sh
chmod 644 ~/.config/ghostty/shaders/shader.glsl
```

### Restart Ghostty
Shader changes require a full restart of Ghostty to take effect.

## Shader Compilation Errors

### Check GLSL syntax
Common syntax issues:
- Missing semicolons at end of statements
- Mismatched parentheses or braces
- Using `int` where `float` is expected (use `1.0` not `1`)

### Verify function signature
The main function must be:
```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord)
```

### Check uniform names
Use the correct uniform names:
- `iResolution` (not `resolution`)
- `iTime` (not `time`)
- `iChannel0` (not `channel0`)

## Performance Issues

### Shader runs slowly
- Reduce iteration counts in loops
- Lower sample counts for blur/bloom effects
- Simplify complex mathematical operations

### Terminal becomes unresponsive
Some complex shaders may be too demanding. Try:
1. Reducing effect intensity
2. Using a simpler shader
3. Checking your GPU drivers are up to date

## Visual Issues

### Text is hard to read
Many shaders are designed to preserve text visibility. If text is obscured:
- Look for `THRESHOLD` or `INTENSITY` defines to adjust
- Ensure the shader properly samples `iChannel0`

### Colors look wrong
- Check color space: some shaders expect linear colors
- Verify alpha channel is preserved: use `color.a` not `1.0`

### Effect only appears in parts of screen
- Ensure UV coordinates are normalized: `fragCoord / iResolution.xy`
- Check for aspect ratio corrections if needed

## Shader Not Animating

### Static instead of animated
- Verify the shader uses `iTime` for animation
- Some shaders are intentionally static (like `negative.glsl`)

### Animation stutters
- Complex shaders may cause frame drops
- Try reducing effect complexity or resolution

## Multiple Shaders

Ghostty currently supports one custom shader at a time. To combine effects:
1. Manually merge shader code
2. Chain effect calculations in a single `mainImage` function

## Getting Help

If you're still having issues:
1. Check the [Ghostty documentation](https://github.com/ghostty-org/ghostty)
2. Open an issue on the [ghostty-shaders repository](https://github.com/hackr-sh/ghostty-shaders)
3. Verify your shader works on [Shadertoy](https://www.shadertoy.com/) first
