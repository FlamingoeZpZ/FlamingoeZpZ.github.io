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
    vec2 uv = gl_FragCoord.xy/u_resolution;
    //woah

    float x = 0.5;
    float y = 0.812;
    vec2 warpedUV = vec2(uv.x, uv.y) - vec2(x,y);// - u_mouse/u_resolution;// u_resolution/gl_FragCoord.xy;//.xy/u_resolution;




    //Polar co-ordinates
    float r = length(warpedUV);
    float theta  = atan(warpedUV.y/warpedUV.x) * 1.164;

    float clampedTime=u_time;
    float b = 3.14;


    r += b * theta;

    warpedUV.x = r;//r * cos(theta);
    warpedUV.y = theta;//r * sin(theta);

    //warpedUV.x = sqrt(warpedUV.x * warpedUV.x + warpedUV.y * warpedUV.y * (warpedUV.x * clampedTime + c) * (warpedUV.x * clampedTime + c));
    //warpedUV.x =  (v*clampedTime + c) * cos(w) *clampedTime;//v * cos(w * clampedTime) - w * (v * clampedTime + c) * sin(w*clampedTime);
    //warpedUV.y =  (v*clampedTime + c) * sin(w) * clampedTime;
    //warpedUV.y = v * sin(w * clampedTime) + w * (v * clampedTime + c) * cos(w*clampedTime);

    //45 % 6 == 3
    //45 / 6 == 7(.5)
    //7 * 6 == 42
    //45-42
    //float timeFrame=1000.;
    //float clampedTime = u_time - floor(u_time / timeFrame) * timeFrame;


    vec3 colA = vec3(0.0, 0.0, 0.2);
    vec3 colB = vec3(1.0, 0.0, 0.0);
    //vec3 col = colorLerp(colA, colB, lerp);


    float circleValue = circle(uv, x, y);
    vec3 col = vec3(circleValue * circleValue * circleValue * circleValue * 1.176);//;


    //Cells
    vec4 stars1 = stars(warpedUV, 8., clampedTime, vec2(0.6,0.1),vec3(1,0.9,0.9));
    vec4 stars2 = stars(warpedUV, 32., clampedTime * 0.1, vec2(0.3,0.05),vec3(1,0.8,0.8));
    vec4 stars3 = stars(warpedUV, 4., clampedTime, vec2(1.2,0.2),vec3(1,1,1));

    //
    gl_FragColor =  (stars1 + stars2+ stars3 + vec4(lerp(vec3(0.000,0.000,0.295),vec3(0.005,0.000,0.000), uv.y),1)) + vec4(col,1);


    //gl_FragColor =  vec4(warpedUV,1,1);
}