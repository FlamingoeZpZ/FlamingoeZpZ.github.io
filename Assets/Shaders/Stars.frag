// Author:
// Title:

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

vec3 lerp(vec3 a, vec3 b, float t)
{
    return a + (b - a) * t;
}

float lerp(float a, float b, float t)
{
    return a + (b - a) * t;
}

float circle(vec2 uv, float x, float y) {
    float xDist = x - uv.x;
    float yDist = y - uv.y;
    float dist = sqrt(xDist * xDist + yDist * yDist);
    return 1.0 - dist;
}

vec4 stars(vec2 st, float cells, float time, vec2 speed, vec3 color)
{
    vec2 cellCount = cells * (st + time * speed);
    vec2 ipos = floor(cellCount);  // get the integer coords
    vec2 fpos = fract(cellCount);  // get the fractional coords

    //Sample over y --> X
    // y= mx+b
    // -1 = x/y
    float up = fpos.x - fpos.y;
    up += fpos.y-fpos.y*5.; // Strange sloping effect

    float t = -0.120;
    up = step(t, up) * step(up, -t);

    float diag = up * pow((0.5-fpos.y) + 1.,4.)-2.;

    //diag = pow(diag,0.);
    float starDist = pow(random(ipos),16.);
    diag = diag * starDist;

    return vec4(vec3(clamp(diag,0.,1.)) * color, starDist);
}

void main() {

    vec2 uv = gl_FragCoord.xy/u_resolution.xy;

    float aspect = u_resolution.x / u_resolution.y;
    if (aspect > 1.0) {
        uv.x = (uv.x - 0.5) * aspect + 0.5;
    } else {
        uv.y = (uv.y - 0.5) / aspect + 0.5; 
    }
    
    
    float duration = 60.;
    //woah

    float x = 0.5;
    float y = 0.8;
    vec2 warpedUV = vec2(uv.x, uv.y) - vec2(x,y);// - u_mouse/u_resolution;// u_resolution/gl_FragCoord.xy;//.xy/u_resolution;
    float scaledTime = (sin(u_time/duration));

    //Polar co-ordinates.
    float r = length(warpedUV);
    float theta  = atan(warpedUV.y/warpedUV.x)  + 0.785398165;// * 0.637;
    float spiralIntensity =1. + u_time * scaledTime * 0.2;
    float bands = 1.581; // 0.637
    r += spiralIntensity + theta * bands;

    r = mod(abs(r), 1.);

    warpedUV = vec2(r,r); // I like this more than actually keeping the stars.
    warpedUV = vec2(r * sin(theta), r * cos(theta)); // Alternative
    //gl_FragColor = vec4(warpedUV.x, warpedUV.y, 1, 1);
    //gl_FragColor = vec4(r);
    //return;


    vec4 background = vec4(lerp(vec3(0.000,0.000,0.295),vec3(0.394,0.098,0.440), uv.y),1);

    gl_FragColor = background;
      
    vec4 stars1 = stars(warpedUV, 8., u_time, vec2(0.6,0.1),vec3(1,0.9,0.9));
    vec4 stars2 = stars(warpedUV, 32., u_time * 0.1, vec2(0.3,0.05),vec3(1,0.8,0.8));
    vec4 stars3 = stars(warpedUV, 4., u_time, vec2(1.2,0.2),vec3(1,1,1));
    vec4 stars = stars1 + stars2+ stars3;

    gl_FragColor += stars;
    
    float circleValue = circle(uv, x, y);
    float blackHole = min(1.,pow(circleValue,32.) * 4.);// * lerp(0.1,1.,scaledTime) + (sin(u_time / k)  * t) * lerp(0.,0.2, scaledTime;
    float pulsation = -(sin(u_time / 1.) * 5. + 10.) * lerp(1.,1.3, scaledTime);
    blackHole *= pulsation;
    vec3 col = lerp(vec3(0),vec3(1), min(1.,blackHole));
    
    //gl_FragColor += vec4(vec3(min(1.,   blackHole)), blackHole);
    gl_FragColor += vec4(vec3( step(0.,circleValue) * blackHole), 1);
    
    
}