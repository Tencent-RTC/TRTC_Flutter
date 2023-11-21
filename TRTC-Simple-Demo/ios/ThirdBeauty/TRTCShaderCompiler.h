//
//  TRTCShaderCompiler.h
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2020/11/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface TRTCShaderCompiler : NSObject

- (instancetype)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;

- (void)prepareToDraw;

- (GLuint)uniformIndex:(NSString *)uniformName;

- (GLuint)attributeIndex:(NSString *)attributeName;

@end
