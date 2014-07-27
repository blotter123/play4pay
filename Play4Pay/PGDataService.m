//
//  PGDataService.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/27/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGDataService.h"

@implementation PGDataService


+ (id)sharedDataService {
    static PGDataService *sharedDS = nil;
    @synchronized(self) {
        if (sharedDS == nil)
            sharedDS = [[self alloc] init];
    }
    return sharedDS;
}


-(void) writeProperty:(NSString*) propertyName withValue:(NSObject*) value{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"data" ofType: @"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    [dict setValue:value forKey:propertyName];
    [dict writeToFile:path atomically:YES];
}

-(NSObject*) readProperty:(NSString*) propertyName{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"data" ofType: @"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    return [dict objectForKey:propertyName];
}

@end
