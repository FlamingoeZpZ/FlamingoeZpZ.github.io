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
    float scaledTime = (sin(u_time/duration));

    //gl_FragColor = vec4(warpedUV.x, warpedUV.y, 1, 1);
    //gl_FragColor = vec4(r);
    //return;


    vec4 background = vec4(lerp(vec3(0.000,0.000,0.295),vec3(0.394,0.098,0.440), uv.y),1);

    gl_FragColor = background;


}