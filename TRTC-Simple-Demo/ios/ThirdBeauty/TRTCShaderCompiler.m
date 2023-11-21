//
//  TRTCShaderCompiler.m
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2020/11/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TRTCShaderCompiler.h"

@interface TRTCShaderCompiler ()

@property (nonatomic) GLuint programHandle;

@end

@implementation TRTCShaderCompiler

- (instancetype)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader {
    if (self = [super init]) {
        [self compileVertexShader:vertexShader fragmentShader:fragmentShader];
    }
    
    return self;
}

- (void)prepareToDraw {
    glUseProgram(self.programHandle);
}

#pragma mark - Private Method

- (GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType {
    NSString *path = [[NSBundle mainBundle] pathForResource:shaderName ofType:nil];
    NSError *error = nil;
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    const char *shaderUTF8 = [shaderString UTF8String];
    GLint shaderLength = (GLint)[shaderString length];
    GLuint shaderHandle = glCreateShader(shaderType);
    glShaderSource(shaderHandle, 1, &shaderUTF8, &shaderLength);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shaderHandle, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandle;
}

- (void)compileVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader {
    GLuint vertexShaderName = [self compileShader:vertexShader withType:GL_VERTEX_SHADER];
    GLuint fragmenShaderName = [self compileShader:fragmentShader withType:GL_FRAGMENT_SHADER];
    
    self.programHandle = glCreateProgram();
    glAttachShader(self.programHandle, vertexShaderName);
    glAttachShader(self.programHandle, fragmenShaderName);
    
    glLinkProgram(self.programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(self.programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
}

- (GLuint)uniformIndex:(NSString *)uniformName {
    return glGetUniformLocation(self.programHandle, [uniformName UTF8String]);
}

- (GLuint)attributeIndex:(NSString *)attributeName {
    return glGetAttribLocation(self.programHandle, [attributeName UTF8String]);
}

@end
