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

float waves(vec2 st, float cells, float time, vec2 speed, vec3 color)
{
    vec2 cellCount = cells * (st + time * speed);
    vec2 ipos = floor(cellCount);  // get the integer coords
    vec2 fpos = fract(cellCount);  // get the fractional coords

    
    float s = fpos.x; // This kind of acts as the layer. where 0 is the closes to the screen and 1 is the farthest...
    
    //We want the waves to clamp on
    
    float k = 1.;
    
    float t = abs(sin(time)) * sin(cos(s * sin(time *k)) + sin(time*k) * 400.);
    
    float n = step(fpos.y, t) * fpos.y;
    
    //Something like y = sin(x); so that we're in terms of Y while context of x
    
    return pow(n, 4.0);
    //Sample over y --> X
    // y= mx+b
    // -1 = x/y
    /*
    float up = fpos.x - fpos.y;
    up += fpos.y-fpos.y*5.; // Strange sloping effect

    float t = -0.120;
    up = step(t, up) * step(up, -t);

    float diag = up * pow((0.5-fpos.y) + 1.,4.)-2.;

    //diag = pow(diag,0.);
    float starDist = pow(random(ipos),16.);
    diag = diag * starDist;

    return vec4(vec3(clamp(diag,0.,1.)) * color, starDist);
    */
}

//This will point towards the sun, and be adjusted by tan to make it wavy?
vec3 clouds(vec2 st, float cells, float time, vec2 speed, vec3 color)
{
    return vec3(0);
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
    float scaledTime = (sin(u_time/duration));

    float waterHeight = 0.440;
	vec3 water = lerp(vec3(0.077,0.268,0.320), vec3(0.478,0.685,0.705), uv.y - waterHeight);
    vec3 sky =   lerp(vec3(0.820,0.368,0.217), vec3(0.985,0.926,0.400), uv.y - waterHeight + 0.15);
    
    vec2 sunLocation = vec2(0.260,0.450);
    float sunDist = length(uv-sunLocation);
    float sunBrightness = 12.;
    vec3 sunColor = vec3(0.980,0.931,0.010);
    
    float waterStep = step(uv.y, waterHeight);
    water *= waterStep;
    sky *= step(waterHeight, uv.y);
	
    float wavesClose = waves(uv, 8., scaledTime, vec2(1,1),vec3(1,0.9,0.9));
    wavesClose *= waterStep;
    
    vec3 sun = pow((1.-sunDist),sunBrightness) * sunColor;
    vec4 background = vec4(water + sky + sun + wavesClose,1) ;

    gl_FragColor = background;


}