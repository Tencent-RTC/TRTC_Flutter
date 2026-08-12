package com.tencent.trtcplugin.render;

import android.opengl.GLES20;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

public class GLDrawer {

    private static final String VERTEX_SHADER =
            "attribute vec4 position;\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "attribute vec4 inputTextureCoordinate;\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "varying vec2 textureCoordinate;\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "void main() {\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "    gl_Position = position;\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "    textureCoordinate = inputTextureCoordinate.xy;\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "}";

    private static final String FRAGMENT_SHADER =
            "varying highp vec2 textureCoordinate;\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "uniform sampler2D inputImageTexture;\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "void main() {\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);\n" +  // CHECKSTYLE:SUPPRESS OperatorWrap
            "}";

    private static final float[] VERTICES = {-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f};

    private static final float[] TEX_COORD_NORMAL   = {0f, 0f, 1f, 0f, 0f, 1f, 1f, 1f};
    private static final float[] TEX_COORD_ROTATE90  = {0f, 1f, 0f, 0f, 1f, 1f, 1f, 0f};
    private static final float[] TEX_COORD_ROTATE180 = {1f, 1f, 0f, 1f, 1f, 0f, 0f, 0f};
    private static final float[] TEX_COORD_ROTATE270 = {1f, 0f, 1f, 1f, 0f, 0f, 0f, 1f};

    private int mProgramId = -1;
    private int mAttribPosition;
    private int mAttribTexCoord;
    private int mUniformTexture;
    private boolean mInitialized;

    public void init() {
        mProgramId = buildProgram(VERTEX_SHADER, FRAGMENT_SHADER);
        if (mProgramId <= 0) {
            return;
        }
        mAttribPosition = GLES20.glGetAttribLocation(mProgramId, "position");
        mAttribTexCoord = GLES20.glGetAttribLocation(mProgramId, "inputTextureCoordinate");
        mUniformTexture = GLES20.glGetUniformLocation(mProgramId, "inputImageTexture");
        mInitialized = true;
    }

    public void destroy() {
        if (mProgramId > 0) {
            GLES20.glDeleteProgram(mProgramId);
            mProgramId = -1;
        }
        mInitialized = false;
    }

    public void draw(int textureId, FloatBuffer vertexBuffer, FloatBuffer texCoordBuffer) {
        if (!mInitialized || textureId < 0) {
            return;
        }

        GLES20.glUseProgram(mProgramId);

        vertexBuffer.position(0);
        GLES20.glVertexAttribPointer(mAttribPosition, 2, GLES20.GL_FLOAT, false, 0, vertexBuffer);
        GLES20.glEnableVertexAttribArray(mAttribPosition);

        texCoordBuffer.position(0);
        GLES20.glVertexAttribPointer(mAttribTexCoord, 2, GLES20.GL_FLOAT, false, 0, texCoordBuffer);
        GLES20.glEnableVertexAttribArray(mAttribTexCoord);

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);
        GLES20.glUniform1i(mUniformTexture, 0);

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);

        GLES20.glDisableVertexAttribArray(mAttribPosition);
        GLES20.glDisableVertexAttribArray(mAttribTexCoord);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
    }

    public static FloatBuffer createVertexBuffer() {
        return toFloatBuffer(VERTICES);
    }

    public static FloatBuffer createTexCoordBuffer() {
        return toFloatBuffer(TEX_COORD_NORMAL);
    }

    public static void updateVertexAndTexCoord(FloatBuffer vertexBuffer, FloatBuffer texCoordBuffer,
                                               boolean centerCrop,
                                               int inputW, int inputH,
                                               int outputW, int outputH) {
        if (inputW <= 0 || inputH <= 0 || outputW <= 0 || outputH <= 0) {
            return;
        }
        float maxRatio = Math.max(1f * outputW / inputW, 1f * outputH / inputH);
        float ratioW = inputW * maxRatio / outputW;
        float ratioH = inputH * maxRatio / outputH;

        float[] texCoords = {0f, 1f, 1f, 1f, 0f, 0f, 1f, 0f};

        if (centerCrop) {
            float distH = (1f - 1f / ratioW) / 2f;
            float distV = (1f - 1f / ratioH) / 2f;
            texCoords = new float[]{
                    offsetTexCoord(texCoords[0], distH), offsetTexCoord(texCoords[1], distV),
                    offsetTexCoord(texCoords[2], distH), offsetTexCoord(texCoords[3], distV),
                    offsetTexCoord(texCoords[4], distH), offsetTexCoord(texCoords[5], distV),
                    offsetTexCoord(texCoords[6], distH), offsetTexCoord(texCoords[7], distV),
            };
            vertexBuffer.clear();
            vertexBuffer.put(VERTICES);
        } else {
            float[] vertices = {
                    VERTICES[0] / ratioH, VERTICES[1] / ratioW,
                    VERTICES[2] / ratioH, VERTICES[3] / ratioW,
                    VERTICES[4] / ratioH, VERTICES[5] / ratioW,
                    VERTICES[6] / ratioH, VERTICES[7] / ratioW,
            };
            vertexBuffer.clear();
            vertexBuffer.put(vertices);
        }

        texCoordBuffer.clear();
        texCoordBuffer.put(texCoords);
    }

    private static float offsetTexCoord(float coord, float dist) {
        return coord == 0f ? dist : 1f - dist;
    }

    private static FloatBuffer toFloatBuffer(float[] data) {
        FloatBuffer buf = ByteBuffer.allocateDirect(data.length * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer();
        buf.put(data).position(0);
        return buf;
    }

    private static int buildProgram(String vertSrc, String fragSrc) {
        int vert = loadShader(GLES20.GL_VERTEX_SHADER, vertSrc);
        int frag = loadShader(GLES20.GL_FRAGMENT_SHADER, fragSrc);
        if (vert == 0 || frag == 0) {
            if (vert != 0) {
                GLES20.glDeleteShader(vert);
            }
            if (frag != 0) {
                GLES20.glDeleteShader(frag);
            }
            return 0;
        }

        int program = GLES20.glCreateProgram();
        GLES20.glAttachShader(program, vert);
        GLES20.glAttachShader(program, frag);
        GLES20.glLinkProgram(program);

        int[] link = new int[1];
        GLES20.glGetProgramiv(program, GLES20.GL_LINK_STATUS, link, 0);
        GLES20.glDeleteShader(vert);
        GLES20.glDeleteShader(frag);
        return link[0] > 0 ? program : 0;
    }

    private static int loadShader(int type, String source) {
        int shader = GLES20.glCreateShader(type);
        GLES20.glShaderSource(shader, source);
        GLES20.glCompileShader(shader);
        int[] compiled = new int[1];
        GLES20.glGetShaderiv(shader, GLES20.GL_COMPILE_STATUS, compiled, 0);
        return compiled[0] != 0 ? shader : 0;
    }
}
