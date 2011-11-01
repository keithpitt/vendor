//
//  DKBenchmark.m
//  DiscoKit
//
//  Created by Keith Pitt on 30/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKBenchmark.h"

@implementation DKBenchmark

+ (void)benchmark:(NSString *)name block:(DKBenchmarkBlock)block {
    
    // If you don't specify an iterations loop, lets just default
    // it to 100.
    [self benchmark:name iterations:100 block:block];
    
}

+ (void)benchmark:(NSString *)name iterations:(NSInteger)iterations block:(DKBenchmarkBlock)block {
    
    // Store the results of the iteration in this array
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    // Define variables that we're going to use in the loop.
    NSDate * date;
    NSTimeInterval timePassed;
    
    for (NSInteger i = 0; i < iterations; i++) {
        
        // Grab the current date
        date = [[NSDate alloc] init];
        
        // Run the block
        block();
        
        // Calcualte the time that has passed, and convert to a
        // signed integer by * -1
        timePassed = [date timeIntervalSinceNow] * -1;
        
        // Release the date
        [date release], date = nil;
        
        // Add the result
        [results addObject:[NSNumber numberWithDouble:timePassed]];
        
    }
    
    // Start at 0
    NSDecimalNumber * average = [NSDecimalNumber decimalNumberWithDecimal:
                                 [[NSNumber numberWithInt:0] decimalValue]];
    
    // Add all our results together
    for (NSNumber * timePassed in results) {
        average = [average decimalNumberByAdding:
                   [NSDecimalNumber decimalNumberWithDecimal:
                    [timePassed decimalValue]]];
    }
    
    // Divide them by the total
    average = [average decimalNumberByDividingBy:
               [NSDecimalNumber decimalNumberWithDecimal:
                [[NSNumber numberWithInt:iterations] decimalValue]]];
    
    // Show the results
    NSLog(@"[DKBenchmark] \"%@\" took %@ seconds on average with (%i iterations)", name, average, iterations);
    
    [results release];
    
}

@end
