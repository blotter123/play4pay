//
//  PGDataService.h
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/27/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGDataService : NSObject

+ (id)sharedDataService;

+(void) writeProperty:(NSString*) propertyName withValue:(NSObject*) value;

-(NSObject*) readProperty:(NSString*) propertyName;


@end
