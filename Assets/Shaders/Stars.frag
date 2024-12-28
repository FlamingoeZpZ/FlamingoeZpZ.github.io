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

vec4 stars(vec2 st, float cells, float time, vec2 speed, vec3 color)
{
    vec2 cellCount = cells * (st + time * speed);
    vec2 ipos = floor(cellCount);  // get the integer coords
    vec2 fpos = fract(cellCount);  // get the fractional coords

    //Sample over y --> X
    // y= mx+b
    // -1 = x/y
    float up = 1. - fpos.x - fpos.y;
    up += 1. - fpos.y-fpos.y*5.; // Strange sloping effect

    float t = -0.120;
    up = step(t, up) * step(up, -t);

    float diag = up * pow((0.5-fpos.y) + 1.,4.)-2.;

    //diag = pow(diag,0.);
    float starDist = pow(random(ipos),16.);
    diag = diag * starDist;

    return vec4(vec3(clamp(diag,0.,1.)) * color, starDist);
}

void main() {
    //vec2 st = gl_FragCoord.xy/u_resolution;
    //woah
    vec2 st = u_resolution/gl_FragCoord.xy;//.xy/u_resolution;

    //45 % 6 == 3
    //45 / 6 == 7(.5)
    //7 * 6 == 42
    //45-42
    //float timeFrame=1000.;
    //float clampedTime = u_time - floor(u_time / timeFrame) * timeFrame;

    float clampedTime=u_time;

    //Cells
    vec4 stars1 = stars(st, 8., clampedTime, vec2(-0.6,0.1),vec3(1,0.9,0.9));
    vec4 stars2 = stars(st, 32., clampedTime*0.1, vec2(-0.3,0.05),vec3(1,0.8,0.8));
    vec4 stars3 = stars(st, 4., clampedTime, vec2(-1.2,0.2),vec3(1,1,1));

    //
    gl_FragColor =   stars1 + stars2+ stars3 + vec4(lerp(vec3(0.000,0.000,0.295),vec3(0.005,0.000,0.000), (gl_FragCoord.xy/u_resolution).y),1);
}