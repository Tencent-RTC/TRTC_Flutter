attribute vec4 a_Position;
attribute vec2 a_TexCoordIn;
varying vec2 v_TexCoordOut;

void main(void) {
    gl_Position = a_Position;
    v_TexCoordOut = a_TexCoordIn;
}
