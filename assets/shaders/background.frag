uniform vec2 resolution;
uniform vec3 blob1;
uniform vec3 blob2;
uniform vec3 blob3;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec3 backgroundColor;

out vec4 fragColor;

vec3 draw_circle(vec2 position, vec3 color, float size) {
    float circle = length(position.xy);

    circle = 1.0 - smoothstep(0.0, size, circle);

    return color * circle;
}

void main() {
    vec2 coord = gl_FragCoord.xy / resolution;
    vec3 canvas = vec3(0);

    canvas += backgroundColor;

    vec3 circle1 = draw_circle(coord - blob1.xy / resolution, color1, blob1.z);
    vec3 circle2 = draw_circle(coord - blob2.xy / resolution, color2, blob2.z);
    vec3 circle3 = draw_circle(coord - blob3.xy / resolution, color3, blob3.z);

    canvas += circle1;
    canvas += circle2;
    canvas += circle3;

    fragColor = vec4(canvas, 1.0);
}