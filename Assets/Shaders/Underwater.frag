#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random (vec2 st) {
    return fract(sin(dot(st.xy,
    vec2(12.9898,78.233)))*
    43758.5453123);
}

float saturate(float s)
{
    return clamp(s, 0.0, 1.0);
}

vec3 lerp(vec3 a, vec3 b, float t)
{
    return a + (b - a) * t;
}

float lerp(float a, float b, float t)
{
    return a + (b - a) * t;
}

float sunBeams(vec2 uv, float time, float angle, float numWaves, float bobSpeed, float speed, float height, float beamPower)
{
    //Okay, lets' try doing a regular rotation instead...
    float scaledTime = cos(time * bobSpeed) * bobSpeed;

    vec2 offset = vec2(0.920 - scaledTime,height + scaledTime) + uv;

    float newX = cos(angle) * offset.x - sin(angle) * offset.y;
    float newY = sin(angle) * offset.x + cos(angle) * offset.y;

    newX =  max(newX, 0.) * min(newX,1.);

    float waves = newY * numWaves;
    float waveIndex=  floor(waves);

    float timePhase = fract(time * speed);
    float beamOffset = random(vec2(waveIndex, 0.0));

    float beamFade = sin((timePhase + beamOffset) * 3.14159 * 2.) * 0.5 + 0.5;

    // Add a threshold to make fewer beams visible
    beamFade = pow(beamFade, beamPower); // Higher power = fewer bright beams

    newX = beamFade * pow(newX,2.) * step(fract(waves),0.99);


    vec2 newUV = vec2(newX,newY);

    return newUV.x;
}


//The AI version was much better than what I could come up with :(
float seaGrass(vec2 uv, float time, float splits, float edgeScale, float bladeWidth, float swayAmount, float waveSpeed, float baseOffsetRange, float heightVariation, float heightMulti)
{
    vec2 scaledUV = uv * vec2(splits, 1.0);
    vec2 floorUV = floor(scaledUV);
    vec2 fractUV = fract(scaledUV);

    // Random per blade
    float random = fract(sin(floorUV.x * 12.9898) * 43758.5453);

    // Random offset for blade base
    float baseOffset = random * baseOffsetRange;

    // Distance from center (0 at center, 1 at edges)
    float distFromCenter = 1. - abs(uv.x - 0.5) * 3.616;

    // Scale blades larger towards edges
    float sizeMultiplier = 1.0 + distFromCenter * edgeScale;

    // Height with variation
    float maxHeight = heightVariation + random * heightMulti;
    maxHeight *= sizeMultiplier;

    // Shift the height comparison upward
    float heightMask = smoothstep(maxHeight + baseOffset, maxHeight + baseOffset - 0.1, uv.y);

    // Normalized height along blade (0 at baseOffset, 1 at top)
    float normalizedHeight = clamp((uv.y - baseOffset) / maxHeight, 0.0, 1.0);

    // Wave motion - more at the top
    float swayStrength = pow(normalizedHeight, 1.5) * swayAmount * sizeMultiplier;
    float sway = sin(time * waveSpeed + floorUV.x * 0.5 + uv.y * 8.0 + random * 6.28) * swayStrength;

    // Apply sway
    fractUV.x += sway;

    // Blade width calculation
    float scaledWidth = bladeWidth * sizeMultiplier;
    float xDist = abs(fractUV.x - 0.5);

    // Taper along height - wider at bottom, narrower at top
    float widthTaper = 1.0 - pow(normalizedHeight, 1.5) * 0.7;

    // Round the top using distance from tip
    float tipRoundness = 0.15 * sizeMultiplier;
    float tipDist = length(vec2(xDist, max(0.0, normalizedHeight - (1.0 - tipRoundness)) / tipRoundness));
    float roundedTip = smoothstep(scaledWidth * 1.2, scaledWidth * 0.8, tipDist);

    // Main blade body
    float blade = smoothstep(scaledWidth * widthTaper, scaledWidth * widthTaper * 0.6, xDist);
    blade = pow(blade, 6.0 / sizeMultiplier);

    // Blend rounded tip with body
    float tipBlendZone = 0.456;
    float tipBlend = smoothstep(tipBlendZone, 0.640, normalizedHeight);
    blade = mix(blade, roundedTip, tipBlend);

    // Apply height mask
    blade *= heightMask;

    // Add texture detail
    float detail = sin(uv.y * 30.0 + random * 10.0) * 0.15 + 0.85;
    blade *= detail;

    // Fade out below base offset
    blade *= smoothstep(baseOffset - 0.05, baseOffset, uv.y);

    return blade;
}

vec3 water(vec2 uv, float time, float sandHeight)
{
    float blending = 0.044;
    float waterStep = step(1.-uv.y, sandHeight);
    float sandStep = 1.- waterStep;

    vec3 bottomSinColor = lerp(vec3(0.152,0.137,0.330), vec3(0.004,0.076,0.150), sin(time * 0.5) + 1. / 2.);
    vec3 highColor = lerp(bottomSinColor,vec3(0.526,1.000,0.854), uv.y) ;
    return highColor;
}

float sand(vec2 uv, float sandArch, float sandHeight)
{
    float t = uv.x - 0.5;
    float s = (t * t) * sandArch * 1.-uv.y + sandHeight;
    return s;
}

float sunDip(vec2 uv, float dip)
{
    float mirror = 2. * uv.x * (1.- uv.x);
    mirror = mirror * pow(uv.y, dip);
    return mirror;
}

void main() {

    vec2 uv = gl_FragCoord.xy/u_resolution.xy;

    // Store original UV for scene positioning
    vec2 sceneUV = uv;

    // Apply aspect correction for visual elements
    float aspect = u_resolution.x / u_resolution.y;
    float t = aspect;
    if (aspect > 1.0) {
        uv.x = (uv.x - 0.5) * aspect + 0.5;
    } else {
        uv.y = (uv.y - 0.5) / aspect + 0.5;
        t = 1./aspect;
    }

    float duration = 4.;
    float scaledTime = (sin(u_time/duration));



    const vec3 sandColor = vec3(0.470,0.411,0.194);

    // Use sceneUV for positioning, aspect-corrected uv for visual effects
    vec3 sky = sandColor * sunDip(sceneUV, 2.508);

    vec3 sand = sandColor * saturate(sand(sceneUV, 0.156, 0.108) * 12.);
    //vec3 col = water(uv, u_time, sandHeight) ;
    //vec3 col = vec3(1) * sunBeams(uv, u_time, 12.000, 0.15, 0.25, -0.3);
    float seaGrassA = seaGrass(sceneUV, u_time, 24. * aspect, -0.876, 0.206, 0.5, 1.352, 0.072, 0.280, 0.084);
    float seaGrassB = seaGrass(sceneUV, u_time, 40. * aspect, -0.460, 0.526, 0.752, 2.552, 0.056, 0.200, 0.028);
    float combo = seaGrassA + seaGrassB;
    vec3 seaGrass = vec3(0.210,0.345,0.136) * saturate(combo);

    vec3 col = sky + sand + water(sceneUV, u_time, 2.604) + sunBeams(sceneUV, u_time, -2.064, 24., 0.1, 0.156, 0.42,12.) + seaGrass;
    //col = sky;
    gl_FragColor = vec4(col, 1.);


}