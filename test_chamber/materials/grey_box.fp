uniform sampler2D floor;
uniform sampler2D wall;
uniform sampler2D ceiling;

varying vec2 var_texcoord0;
varying float diff_light;
varying float texture_use;

vec3 selectTexture(float condition)
{
    vec2 uv = var_texcoord0.xy * 1;
    if (texture_use > 0.35)
        return texture2D(floor, uv).rgb;
    else if (texture_use < -0.35)
        return texture2D(ceiling, uv).rgb;
    else
        return texture2D(wall, uv).rgb;
}

void main()
{        
    gl_FragColor = vec4((diff_light + vec3(0.2)) * selectTexture(texture_use), 1.0);
}

