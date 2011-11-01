//
//  DKBenchmark.h
//  DiscoKit
//
//  Created by Keith Pitt on 30/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DKBenchmarkBlock)(void);

@interface DKBenchmark : NSObject

+ (void)benchmark:(NSString *)name block:(DKBenchmarkBlock)block;
+ (void)benchmark:(NSString *)name iterations:(NSInteger)iterations block:(DKBenchmarkBlock)block;

@end