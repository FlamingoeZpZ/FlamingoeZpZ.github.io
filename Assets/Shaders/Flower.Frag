#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec3 flowerPetals(float dist, float theta, float scale, float petals, float push, float blur)
{
    float r = abs(sin(petals * theta)) * scale + push;

    float x = r * cos(theta) ;
    float y = r * sin(theta) ;

    float b = smoothstep(blur, 0., dist - r);
    
    return vec3(x,y,b);
}

// HSV to RGB conversion (chatgpt)
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

    vec2 uv = gl_FragCoord.xy/u_resolution.xy;
    float aspect = u_resolution.x / u_resolution.y;
    if (aspect > 1.0) {
        uv.x = (uv.x - 0.5) * aspect + 0.5;
    } else {
        uv.y = (uv.y - 0.5) / aspect + 0.5;
    }
    float pivotX = 0.5;
    float pivotY = 0.8;
    vec2 warpedUV = vec2(uv.x, uv.y) - vec2(pivotX,pivotY);

    warpedUV *= 3.14159;

    //Polar co-ordinates.
    float dist = length(warpedUV);
    float theta  = atan(warpedUV.y/warpedUV.x);
    
    vec3 a = flowerPetals(dist, theta, 0.1, 8., 0.5, 0.1);
    a += flowerPetals(dist, theta, 0.5, 8., 0., 0.1);
    //a += flowerPetals(dist, theta, 0.05, 5., 0.5, 0.05);
    //a += flowerPetals(dist, theta, 0.03, 4., 0.5, 0.03);
    //vec4 b = vec4(0,flowerPetals(dist, theta, 0.8, 4., 0., 0.1),0, 0.5);
   // vec4 c = vec4(0,0,flowerPetals(dist, theta, 0.4, 2.0, 0., 0.1), 1.);
    vec3 col = hsv2rgb(vec3(theta * 3.14159 * 0.1 * (u_time), 1.0, 1.0)) * a.z - step(0.99,a.z);

    gl_FragColor = vec4(col,1.);// + b + c;

}