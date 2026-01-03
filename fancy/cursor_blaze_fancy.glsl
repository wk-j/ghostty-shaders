// Fancy Cursor Blaze - Enhanced cursor trail with particles, glow, and rainbow effects
// Based on cursor_blaze.glsl with added visual effects

// ============ CONFIGURATION ============
#define TRAIL_DURATION 0.8           // How long the trail lasts
#define GLOW_INTENSITY 1.5           // Glow brightness (reduced for less flash)
#define GLOW_SIZE 4.0                // Glow spread (higher = smaller glow)
#define PARTICLE_COUNT 12            // Number of particles in trail
#define PARTICLE_SIZE 0.08           // Size of particles (as ratio of cursor)
#define RAINBOW_MODE true            // Enable rainbow colors
#define RAINBOW_SPEED 2.0            // Rainbow color cycle speed
#define WAVE_AMPLITUDE 0.03          // Wave motion amplitude
#define WAVE_FREQUENCY 8.0           // Wave motion frequency
#define SPARKLE_INTENSITY 0.8        // Sparkle brightness (reduced for less flash)
#define DRAW_THRESHOLD 1.0           // Minimum distance to draw trail (lower = more trails)
#define HIDE_TRAILS_ON_SAME_LINE false
#define TRAIL_THICKNESS 1.0          // Trail thickness multiplier (1.0 = exact cursor width)
#define COLOR_SATURATION 0.8         // Color saturation (lower = lighter/pastel)
#define COLOR_BRIGHTNESS 1.1         // Color brightness boost (reduced for less flash)

// Base colors (used when RAINBOW_MODE is false) - lighter tones
const vec3 BASE_COLOR = vec3(1.0, 0.5, 0.3);      // Light Orange
const vec3 ACCENT_COLOR = vec3(1.0, 1.0, 0.6);    // Light Yellow
// ========================================

// Hash function for randomness
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float hash2(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Easing functions
float easeOutExpo(float x) {
    return x == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * x);
}

float easeOutElastic(float x) {
    float c4 = (2.0 * 3.14159) / 3.0;
    return x == 0.0 ? 0.0 : x == 1.0 ? 1.0 : pow(2.0, -10.0 * x) * sin((x * 10.0 - 0.75) * c4) + 1.0;
}

float easeInOutCubic(float x) {
    return x < 0.5 ? 4.0 * x * x * x : 1.0 - pow(-2.0 * x + 2.0, 3.0) / 2.0;
}

// Rainbow color generator - lighter pastel tones
vec3 rainbow(float t) {
    vec3 c = 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
    // Mix with white to make lighter/pastel, then apply brightness
    c = mix(vec3(1.0), c, COLOR_SATURATION) * COLOR_BRIGHTNESS;
    return clamp(c, 0.0, 1.0);
}

// HSV to RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// SDF for box with rounded corners (standard)
float sdBoxRounded(vec2 p, vec2 center, vec2 size) {
    vec2 d = abs(p - center) - size;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// SDF for box with sharp corners (no rounding) - Chebyshev distance
float sdBox(vec2 p, vec2 center, vec2 size) {
    vec2 d = abs(p - center) - size;
    return max(d.x, d.y);
}

// SDF for circle
float sdCircle(vec2 p, vec2 center, float radius) {
    return length(p - center) - radius;
}

// SDF for rounded line segment
float sdSegment(vec2 p, vec2 a, vec2 b, float r) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

// Parallelogram SDF (from original)
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);
    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(vec2 p, vec2 v0, vec2 v1, vec2 v2, vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);
    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);
    return s * sqrt(d);
}

vec2 normalizeCoord(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y);
    float condition2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.0), rectangle.y - (rectangle.w / 2.0));
}

// Glow effect - tighter/smaller glow
float glow(float d, float intensity, float size) {
    return intensity / (1.0 + pow(max(0.0, d) * size * 80.0, 2.0));
}

// Outer glow - tighter spread
float outerGlow(float d, float intensity) {
    return intensity * exp(-max(0.0, d) * 30.0);
}

// Box-shaped glow using SDF - tighter spread
float boxGlow(vec2 p, vec2 center, vec2 size, float intensity, float falloff) {
    float d = sdBox(p, center, size);
    return intensity * exp(-max(0.0, d) * falloff * 2.0);
}

// Sparkle effect
float sparkle(vec2 uv, float time) {
    float n = hash(floor(uv * 50.0));
    float t = fract(time * 3.0 + n * 6.28);
    return pow(max(0.0, sin(t * 3.14159)), 10.0) * step(0.97, n);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    
    vec2 uv = normalizeCoord(fragCoord, 1.0);
    vec2 offsetFactor = vec2(-0.5, 0.5);
    
    // Normalize cursor positions
    vec4 currentCursor = vec4(normalizeCoord(iCurrentCursor.xy, 1.0), normalizeCoord(iCurrentCursor.zw, 0.0));
    vec4 previousCursor = vec4(normalizeCoord(iPreviousCursor.xy, 1.0), normalizeCoord(iPreviousCursor.zw, 0.0));
    
    // Calculate centers and distance
    vec2 centerCurrent = getRectangleCenter(currentCursor);
    vec2 centerPrevious = getRectangleCenter(previousCursor);
    float cursorSize = max(currentCursor.z, currentCursor.w);
    float trailThreshold = DRAW_THRESHOLD * cursorSize;
    float lineLength = distance(centerCurrent, centerPrevious);
    
    // Check if we should draw
    bool isFarEnough = lineLength > trailThreshold;
    bool isOnSeparateLine = HIDE_TRAILS_ON_SAME_LINE ? currentCursor.y != previousCursor.y : true;
    
    if (isFarEnough && isOnSeparateLine) {
        // Progress calculation
        float rawProgress = clamp((iTime - iTimeCursorChange) / TRAIL_DURATION, 0.0, 1.0);
        float progress = easeOutExpo(rawProgress);
        float fadeOut = 1.0 - rawProgress;
        
        // Direction vector
        vec2 direction = normalize(centerCurrent - centerPrevious);
        vec2 perpendicular = vec2(-direction.y, direction.x);
        
        // Vertex factor for parallelogram
        float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
        float invertedVertexFactor = 1.0 - vertexFactor;
        
        // Parallelogram vertices
        vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
        vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
        vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor, previousCursor.y);
        vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);
        
        // Calculate SDFs
        float sdfTrail = getSdfParallelogram(uv, v0, v1, v2, v3);
        float sdfCursor = sdBox(uv, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
        
        // Distance along trail for gradient - use box distance instead of circular
        float distanceToEnd = max(abs(uv.x - centerCurrent.x), abs(uv.y - centerCurrent.y));
        float trailPosition = clamp(distanceToEnd / lineLength, 0.0, 1.0);
        
        // Dynamic color
        vec3 trailColor;
        if (RAINBOW_MODE) {
            float hue = iTime * RAINBOW_SPEED * 0.1 + trailPosition * 0.5;
            trailColor = rainbow(hue);
        } else {
            trailColor = mix(BASE_COLOR, ACCENT_COLOR, trailPosition);
        }
        
        // Wave distortion on trail - only apply for longer jumps, not typing
        float minWaveDistance = cursorSize * 5.0;  // Only wave when jumping more than 5 cursor widths
        float waveStrength = smoothstep(minWaveDistance, minWaveDistance * 2.0, lineLength);
        float wave = sin(trailPosition * WAVE_FREQUENCY + iTime * 5.0) * WAVE_AMPLITUDE * fadeOut * waveStrength;
        vec2 waveOffset = perpendicular * wave;
        float sdfTrailWave = getSdfParallelogram(uv - waveOffset, v0, v1, v2, v3);
        
        // Cursor-shaped trail with natural tail effect
        vec2 cursorCenter = currentCursor.xy - (currentCursor.zw * offsetFactor);
        vec2 cursorHalfSize = currentCursor.zw * 0.5;
        
        // Main trail core
        float trailCore = smoothstep(0.002, -0.002, sdfTrailWave) * fadeOut;
        
        // Subtle glow around trail
        float trailGlow = glow(sdfTrailWave, GLOW_INTENSITY * 0.4, GLOW_SIZE * 2.0) * fadeOut;
        
        // Natural tail effect - cursor-shaped segments fading along the trail
        float tailEffect = 0.0;
        int tailSegments = 8;
        
        for (int i = 0; i < tailSegments; i++) {
            float fi = float(i);
            float t = fi / float(tailSegments - 1);  // 0 to 1 along trail
            
            // Position along the trail (from previous to current cursor)
            vec2 tailPos = mix(centerPrevious, centerCurrent, t);
            
            // Each segment fades based on distance from current cursor
            float segmentFade = (1.0 - t) * fadeOut;  // Stronger near current, fades toward previous
            
            // Slight size reduction for segments further from cursor
            float sizeScale = 0.6 + 0.4 * (1.0 - t);
            vec2 segmentSize = cursorHalfSize * sizeScale;
            
            // Cursor-shaped segment
            float segmentSdf = sdBox(uv, tailPos, segmentSize);
            float segment = smoothstep(0.001, -0.001, segmentSdf);
            
            // Soft glow around each segment
            float segmentGlow = exp(-max(0.0, segmentSdf) * 50.0) * 0.3;
            
            tailEffect += (segment + segmentGlow) * segmentFade * 0.4;
        }
        
        // Combine effects
        vec3 effectColor = trailColor;
        float effectAlpha = 0.0;
        
        // Add tail effect
        effectAlpha += tailEffect * 0.7;
        
        // Add subtle glow
        effectAlpha += trailGlow * 0.25;
        
        // Add solid trail core
        effectAlpha += trailCore * 0.5;
        
        // Fade based on animation progress
        float distanceFade = 1.0 - progress;
        effectAlpha *= distanceFade;
        
        // Clamp alpha - allow higher values for additive-like effect
        effectAlpha = clamp(effectAlpha, 0.0, 1.0);
        
        // Blend with original using stronger alpha
        vec3 finalColor = mix(fragColor.rgb, effectColor, effectAlpha);
        
        // Add additive glow on top for extra brightness
        finalColor += effectColor * trailGlow * 0.15 * fadeOut;
        
        // Don't draw over the cursor itself
        finalColor = mix(finalColor, fragColor.rgb, step(sdfCursor, 0.0));
        
        fragColor = vec4(finalColor, fragColor.a);
    }
}
