// Glide: on a jump the cursor slides into place, trailing a short streak
// that fades out behind it.

const float DURATION = 0.12;   // seconds until the tail arrives
const float HEAD_SHARE = 0.5;  // fraction of DURATION the head takes to arrive
const float MAX_STREAK = 5.0;  // longest visible streak, in cursor heights
const float MIN_JUMP = 1.5;    // shorter moves (in cursor heights) don't animate
const float SOFTNESS = 2.5;    // edge feather, in pixels

float easeOutQuart(float t) {
    t = clamp(t, 0.0, 1.0);
    return 1.0 - pow(1.0 - t, 4.0);
}

float boxDistance(vec2 p, vec2 halfSize) {
    vec2 q = abs(p) - halfSize;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

// Ghostty gives the cursor's top-left corner in pixels, with y growing upward.
vec2 cursorCenter(vec4 c) {
    return vec2(c.x + c.z * 0.5, c.y - c.w * 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 base = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = base;

    vec2 from = cursorCenter(iPreviousCursor);
    vec2 to = cursorCenter(iCurrentCursor);
    vec2 halfSize = iCurrentCursor.zw * 0.5;
    float jump = distance(from, to);
    float elapsed = iTime - iTimeCursorChange;

    if (jump < MIN_JUMP * iCurrentCursor.w || elapsed >= DURATION) {
        return;
    }

    // Everything is measured as distance still to go before the landing point,
    // and clipped to MAX_STREAK so nothing shows mid-path on long jumps.
    vec2 dir = (to - from) / jump;
    float reach = MAX_STREAK * iCurrentCursor.w;
    float headLeft = min(jump * (1.0 - easeOutQuart(elapsed / (DURATION * HEAD_SHARE))), reach);
    float tailLeft = min(jump * (1.0 - easeOutQuart(elapsed / DURATION)), reach);

    // the cursor box swept between tail and head
    float behind = dot(to - fragCoord, dir);
    vec2 center = to - dir * clamp(behind, headLeft, tailLeft);
    float d = boxDistance(fragCoord - center, halfSize);
    float coverage = 1.0 - smoothstep(-SOFTNESS * 0.5, SOFTNESS * 0.5, d);

    float fade = 1.0 - smoothstep(0.0, reach, behind);
    float alpha = coverage * fade * iCurrentCursorColor.a;

    // never paint over the real cursor
    if (boxDistance(fragCoord - to, halfSize) <= 0.0) {
        alpha = 0.0;
    }

    // cursor colour arrives as sRGB; the frame is blended in linear space
    vec3 color = pow(iCurrentCursorColor.rgb, vec3(2.2));
    fragColor = vec4(mix(base.rgb, color, alpha), base.a);
}
