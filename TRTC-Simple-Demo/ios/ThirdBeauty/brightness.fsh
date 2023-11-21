uniform sampler2D u_Texture;
varying highp vec2 v_TexCoordOut;
uniform lowp float brightness;

void main()
{
    lowp vec4 textureColor = texture2D(u_Texture, v_TexCoordOut);
    gl_FragColor = vec4((textureColor.rgb + vec3(brightness)), textureColor.w);
}
