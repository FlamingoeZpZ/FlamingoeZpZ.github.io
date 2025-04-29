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

    gl_FragColor = vec4(uv.x, uv.y, 0, 1);
    
}