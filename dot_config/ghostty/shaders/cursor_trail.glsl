// Cursor trail, imitating kitty's `cursor_trail 1`.
// A parallelogram is stretched between the previous and the current cursor
// position and shrinks towards the current one.

const float DURATION = 0.25;        // seconds the trail takes to catch up
const float START_THRESHOLD = 0.75; // min jump (in cursor heights) before a trail is drawn;
                                    // ~2 cells, like kitty's cursor_trail_start_threshold
const float OPACITY = 0.8;

float sdfRectangle(in vec2 p, in vec2 center, in vec2 halfSize) {
    vec2 d = abs(p - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Based on Inigo Quilez's 2D distance functions
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    d = min(d, dot(p - proj, p - proj));

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    s *= mix(1.0, -1.0, step(0.5, allCond + noneCond));
    return d;
}

float sdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);
    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);
    return s * sqrt(d);
}

// Pixel coordinates -> aspect-corrected [-1, 1] space
vec2 norm(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialias(float dist) {
    return 1.0 - smoothstep(0.0, norm(vec2(2.0), 0.0).x, dist);
}

// Picks which cursor corners the trail hangs off, depending on move direction
float startVertexFactor(vec2 a, vec2 b) {
    float c1 = step(b.x, a.x) * step(a.y, b.y);
    float c2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(c1, c2);
}

vec2 rectCenter(vec4 r) {
    return vec2(r.x + r.z * 0.5, r.y - r.w * 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);

    vec2 uv = norm(fragCoord, 1.0);
    vec4 cur = vec4(norm(iCurrentCursor.xy, 1.0), norm(iCurrentCursor.zw, 0.0));
    vec4 prev = vec4(norm(iPreviousCursor.xy, 1.0), norm(iPreviousCursor.zw, 0.0));

    vec2 centerCur = rectCenter(cur);
    vec2 centerPrev = rectCenter(prev);
    float lineLength = distance(centerCur, centerPrev);
    if (lineLength < cur.w * START_THRESHOLD) return;

    float vf = startVertexFactor(cur.xy, prev.xy);
    float ivf = 1.0 - vf;
    vec2 v0 = vec2(cur.x + cur.z * vf, cur.y - cur.w);
    vec2 v1 = vec2(cur.x + cur.z * ivf, cur.y);
    vec2 v2 = vec2(prev.x + cur.z * ivf, prev.y);
    vec2 v3 = vec2(prev.x + cur.z * vf, prev.y - prev.w);

    float sdfCursor = sdfRectangle(uv, centerCur, cur.zw * 0.5);
    float sdfTrail = sdfParallelogram(uv, v0, v1, v2, v3);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float eased = pow(1.0 - progress, 3.0);

    vec4 trail = vec4(iCursorColor, 1.0);
    vec4 withTrail = mix(fragColor, trail, antialias(sdfTrail) * OPACITY);
    withTrail = mix(withTrail, fragColor, step(sdfCursor, 0.0));
    fragColor = mix(fragColor, withTrail, step(sdfCursor, eased * lineLength));
}
