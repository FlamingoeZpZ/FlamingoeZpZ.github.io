precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

vec3 colorLerp(vec3 a, vec3 b, float t) {
    return a + (b - a) * t;
}

float circle(vec2 uv, float x, float y) {
    float xDist = x - uv.x;
    float yDist = y - uv.y;
    float dist = sqrt(xDist * xDist + yDist * yDist);
    return 1.0 - dist;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;

    float lerp = st.y * st.y;

    vec3 colA = vec3(0.0, 0.0, 0.2);
    vec3 colB = vec3(1.0, 0.0, 0.0);
    //vec3 col = colorLerp(colA, colB, lerp);

    float x = 0.5;
    float y = 0.8;

    float circleValue = circle(st, x, y);
    vec3 col = vec3((circleValue * circleValue),0.,0.);//;

    gl_FragColor = vec4(col, 1);
}