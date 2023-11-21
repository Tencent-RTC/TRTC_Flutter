//
//  TRTCVideoCustomPreprocessor.m
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2020/11/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TRTCVideoCustomPreprocessor.h"
#import "TRTCShaderCompiler.h"
#import <OpenGLES/ES2/glext.h>

@interface TRTCVideoCustomPreprocessor()

@property (nonatomic) BOOL isTextureValid;
@property (nonatomic) uint32_t width;
@property (nonatomic) uint32_t height;

@property (nonatomic) GLuint brightnessUniform;
@property (nonatomic) GLuint brightnessPositionSlot;
@property (nonatomic) GLuint brightnessTextureSlot;
@property (nonatomic) GLuint brightnessTextureCoordSlot;

@property (nonatomic) GLuint brightnessFramebuffer;
@property (nonatomic) GLuint brightnessTexture;
@property (nonatomic, strong) TRTCShaderCompiler *brightnessShader;

@end


@implementation TRTCVideoCustomPreprocessor

- (void)processFrame:(TRTCVideoFrame *)srcFrame dstFrame:(TRTCVideoFrame *)dstFrame {
    if ([self needToCreateBufferWithWidth:srcFrame.width height:srcFrame.height]) {
        [self createFrameBufferWithFrame:dstFrame];
        [self createShader];
    }

    [self drawTexture:srcFrame.textureId width:srcFrame.width height:srcFrame.height];
}

- (GLuint)processTexture:(GLuint)textureId width:(uint32_t)width height:(uint32_t)height {
    if ([self needToCreateBufferWithWidth:width height:height]) {
        [self createFrameBufferWithWidth:width height:height];
        [self createShader];
    }
    
    [self drawTexture:textureId width:width height:height];
    return self.brightnessTexture;
}

- (void)invalidateBindedTexture {
    self.isTextureValid = NO;
}

#pragma mark - Private

- (BOOL)needToCreateBufferWithWidth:(uint32_t)width height:(uint32_t)height {
    return self.brightnessFramebuffer == 0 || self.width != width || self.height != height || !self.isTextureValid;
}

- (void)createFrameBufferWithFrame:(TRTCVideoFrame *)frame {
    glGenFramebuffers(1, &_brightnessFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _brightnessFramebuffer);

    glBindTexture(GL_TEXTURE_2D, frame.textureId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, frame.textureId, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Error - failed to create framebuffer: %x", status);
    }
    
    self.width = frame.width;
    self.height = frame.height;
    self.isTextureValid = YES;
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE, 0);
}

- (void)createFrameBufferWithWidth:(uint32_t)width height:(uint32_t)height {
    glGenFramebuffers(1, &_brightnessFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _brightnessFramebuffer);
    
    glGenTextures(1, &_brightnessTexture);
    glBindTexture(GL_TEXTURE_2D, _brightnessTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, NULL);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _brightnessTexture, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Error - failed to create framebuffer: %x", status);
    }
    
    self.width = width;
    self.height = height;
    self.isTextureValid = YES;
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE, 0);
}

- (void)createShader {
    self.brightnessShader = [[TRTCShaderCompiler alloc] initWithVertexShader:@"vertexShader.vsh" fragmentShader:@"brightness.fsh"];
    [self.brightnessShader prepareToDraw];
    self.brightnessPositionSlot = [self.brightnessShader attributeIndex:@"a_Position"];
    self.brightnessTextureSlot = [self.brightnessShader uniformIndex:@"u_Texture"];
    self.brightnessTextureCoordSlot = [self.brightnessShader attributeIndex:@"a_TexCoordIn"];
    self.brightnessUniform = [self.brightnessShader uniformIndex:@"brightness"];
}

- (void)drawTexture:(GLuint)textureId width:(uint32_t)width height:(uint32_t)height {
    glBindFramebuffer(GL_FRAMEBUFFER, _brightnessFramebuffer);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, width, height);
    
    [self.brightnessShader prepareToDraw];
    glUniform1f(self.brightnessUniform, self.brightness);
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(self.brightnessTextureSlot, 5);
    
    const GLfloat vertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f, 1.0f,
        1.0f, 1.0f
    };
    
    glEnableVertexAttribArray(self.brightnessPositionSlot);
    glVertexAttribPointer(self.brightnessPositionSlot, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    
    const GLfloat coords[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    glEnableVertexAttribArray(self.brightnessTextureCoordSlot);
    glVertexAttribPointer(self.brightnessTextureCoordSlot, 2, GL_FLOAT, GL_FALSE, 0, coords);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
