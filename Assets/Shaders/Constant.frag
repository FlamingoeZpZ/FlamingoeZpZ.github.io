// Author:
// Title:

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


void main() {

    vec2 uv = gl_FragCoord.xy/u_resolution.xy;

    float aspect = u_resolution.x / u_resolution.y;
    if (aspect > 1.0) {
        uv.x = (uv.x - 0.5) * aspect + 0.5;
    } else {
        uv.y = (uv.y - 0.5) / aspect + 0.5; 
    }
    
    /*
    float duration = 60.;
    float x = 0.5;
    float y = 0.8;
    vec2 warpedUV = vec2(uv.x, uv.y) - vec2(x,y);// - u_mouse/u_resolution;// u_resolution/gl_FragCoord.xy;//.xy/u_resolution;
    float scaledTime = (sin(u_time/duration));
    */

    /*
    //Polar co-ordinates.
    float r = length(warpedUV);
    float theta  = atan(warpedUV.y/warpedUV.x)  + 0.785398165;// * 0.637;
    */
    
    gl_FragColor = vec4(vec3(0.5), 1);
    
    
}