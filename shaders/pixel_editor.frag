#include <flutter/runtime_effect.glsl>

// Inputs from Flutter
uniform vec2 uSize;          // Size of the view (screen width/height)
uniform vec2 uCanvasSize;    // Size of the pixel art (e.g., 512x512)
uniform vec2 uOffset;        // Pan offset
uniform float uZoom;         // Zoom level
uniform vec4 uGridColor;     // Color of the grid
uniform sampler2D uTexture;  // The actual pixel art data (cached image)

out vec4 fragColor;

void main() {
    // 1. Get current screen pixel coordinate
    vec2 screenPos = FlutterFragCoord().xy;

    // 2. Transform screen coordinate to Canvas coordinate (Inverse Matrix)
    // (screen - offset) / zoom
    vec2 canvasPos = (screenPos - uOffset) / uZoom;

    // 3. Check if we are outside the canvas bounds
    if (canvasPos.x < 0.0 || canvasPos.x >= uCanvasSize.x ||
        canvasPos.y < 0.0 || canvasPos.y >= uCanvasSize.y) {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0); // Transparent background
        return;
    }

    // 4. Sample the color from the texture
    // We normalize canvasPos to 0.0 - 1.0 range for the texture sampler
    vec2 uv = canvasPos / uCanvasSize;
    vec4 pixelColor = texture(uTexture, uv);

    // 5. Grid Logic (Optional, but very fast here)
    // Determine if we are at the edge of a virtual pixel
    // frac(canvasPos) gives us the decimal part (0.0 to 0.99 inside a pixel)
    if (uZoom > 4.0) { // Only show grid if zoomed in
        vec2 gridDist = abs(fract(canvasPos) - 0.5);
        // If we are near the edge (0.5 - distance < thickness)
        // 0.45 represents grid thickness relative to pixel
        if (gridDist.x > 0.48 || gridDist.y > 0.48) {
            // Blend grid color on top of pixel color
            pixelColor = mix(pixelColor, uGridColor, 0.3);
        }
    }

    fragColor = pixelColor;
}