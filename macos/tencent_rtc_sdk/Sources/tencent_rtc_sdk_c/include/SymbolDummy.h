//
//  SymbolDummy.h
//  Pods
//
//  Created by vincepzhang on 2024/7/2.
//

#import <Foundation/Foundation.h>

typedef void (*LiteavCFunction)(int);

@interface LiteavSymbolDeclarationClass : NSObject
+ (void)liteavCFunction;
@end
