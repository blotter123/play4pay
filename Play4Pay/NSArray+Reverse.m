//
//  NSArray+Reverse.m
//  Play4Pay
//
//  Created by Julian Offermann on 9/13/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

- (NSArray*) reversedArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end
